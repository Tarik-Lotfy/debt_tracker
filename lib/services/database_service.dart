import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/debt.dart';
import '../models/payment.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Singleton pattern
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'debt_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Drop old tables and recreate them
      await db.execute('DROP TABLE IF EXISTS payments');
      await db.execute('DROP TABLE IF EXISTS debts');

      // Recreate tables with new schema
      await _createDatabase(db, newVersion);
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create debts table
    await db.execute('''
      CREATE TABLE debts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        paidAmount REAL NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Create payments table
    await db.execute('''
      CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debtId INTEGER NOT NULL,
        amount REAL NOT NULL,
        paymentDate INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY(debtId) REFERENCES debts(id) ON DELETE CASCADE
      )
    ''');
  }

  // DEBT OPERATIONS
  Future<int> insertDebt(Debt debt) async {
    final db = await database;
    return await db.insert('debts', debt.toMap());
  }

  Future<List<Debt>> getAllDebts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('debts');
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  Future<Debt?> getDebt(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Debt.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDebt(Debt debt) async {
    final db = await database;
    return await db.update(
      'debts',
      debt.toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  Future<int> deleteDebt(int id) async {
    final db = await database;
    return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  // PAYMENT OPERATIONS
  Future<int> insertPayment(Payment payment) async {
    final db = await database;

    // First insert the payment
    final paymentId = await db.insert('payments', payment.toMap());

    // Then update the debt's paid amount
    final List<Map<String, dynamic>> debtMaps = await db.query(
      'debts',
      where: 'id = ?',
      whereArgs: [payment.debtId],
    );

    if (debtMaps.isNotEmpty) {
      final debt = Debt.fromMap(debtMaps.first);
      final updatedDebt = debt.copyWith(
        paidAmount: debt.paidAmount + payment.amount,
      );

      await db.update(
        'debts',
        updatedDebt.toMap(),
        where: 'id = ?',
        whereArgs: [debt.id],
      );
    }

    return paymentId;
  }

  Future<List<Payment>> getPaymentsForDebt(int debtId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'debtId = ?',
      whereArgs: [debtId],
      orderBy: 'paymentDate DESC',
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    final db = await database;

    // First get the payment details
    final List<Map<String, dynamic>> paymentMaps = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (paymentMaps.isNotEmpty) {
      final payment = Payment.fromMap(paymentMaps.first);

      // Get the debt
      final List<Map<String, dynamic>> debtMaps = await db.query(
        'debts',
        where: 'id = ?',
        whereArgs: [payment.debtId],
      );

      if (debtMaps.isNotEmpty) {
        final debt = Debt.fromMap(debtMaps.first);

        // Update the debt's paid amount
        final updatedDebt = debt.copyWith(
          paidAmount: debt.paidAmount - payment.amount,
        );

        await db.update(
          'debts',
          updatedDebt.toMap(),
          where: 'id = ?',
          whereArgs: [debt.id],
        );
      }
    }

    // Then delete the payment
    return await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }
}
