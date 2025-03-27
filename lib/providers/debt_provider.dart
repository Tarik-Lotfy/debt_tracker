import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../services/database_service.dart';

class DebtProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Debt> _debts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active debts (not fully paid)
  List<Debt> get activeDebts =>
      _debts.where((debt) => !debt.isFullyPaid).toList();

  // Get total amount owed across all debts
  double get totalAmountOwed =>
      _debts.fold(0, (total, debt) => total + debt.remainingAmount);

  // Initialize and load debts
  Future<void> loadDebts() async {
    _setLoading(true);
    _error = null;

    try {
      _debts = await _databaseService.getAllDebts();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load debts: $e');
    }
  }

  // Add a new debt
  Future<bool> addDebt(Debt debt) async {
    _setLoading(true);
    _error = null;

    try {
      final id = await _databaseService.insertDebt(debt);
      final newDebt = debt.copyWith(id: id);
      _debts.add(newDebt);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add debt: $e');
      return false;
    }
  }

  // Update an existing debt
  Future<bool> updateDebt(Debt debt) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.updateDebt(debt);
      final index = _debts.indexWhere((d) => d.id == debt.id);
      if (index != -1) {
        _debts[index] = debt;
      }
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update debt: $e');
      return false;
    }
  }

  // Delete a debt
  Future<bool> deleteDebt(int id) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.deleteDebt(id);
      _debts.removeWhere((debt) => debt.id == id);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete debt: $e');
      return false;
    }
  }

  // Update debt paid amount after a payment is made
  Future<bool> updateDebtPaidAmount(int debtId, double additionalAmount) async {
    final index = _debts.indexWhere((debt) => debt.id == debtId);
    if (index == -1) return false;

    final debt = _debts[index];
    final updatedDebt = debt.copyWith(
      paidAmount: debt.paidAmount + additionalAmount,
    );

    return await updateDebt(updatedDebt);
  }

  // Get a specific debt by id
  Debt? getDebtById(int id) {
    try {
      return _debts.firstWhere((debt) => debt.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper methods to set state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
