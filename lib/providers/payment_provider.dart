import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class PaymentProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  Map<int, List<Payment>> _paymentsByDebtId = {}; // Map debt ID to its payments
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<int, List<Payment>> get paymentsByDebtId => _paymentsByDebtId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load payments for a specific debt
  Future<void> loadPaymentsForDebt(int debtId) async {
    _setLoading(true);
    _error = null;

    try {
      final payments = await _databaseService.getPaymentsForDebt(debtId);
      _paymentsByDebtId[debtId] = payments;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load payments for debt: $e');
    }
  }

  // Add a new payment
  Future<bool> addPayment(Payment payment) async {
    _setLoading(true);
    _error = null;

    try {
      final id = await _databaseService.insertPayment(payment);
      final newPayment = payment.copyWith(id: id);

      // Update payment lists
      if (_paymentsByDebtId.containsKey(payment.debtId)) {
        _paymentsByDebtId[payment.debtId]!.add(newPayment);
        _paymentsByDebtId[payment.debtId]!.sort(
          (a, b) => b.paymentDate.compareTo(a.paymentDate),
        );
      } else {
        _paymentsByDebtId[payment.debtId] = [newPayment];
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add payment: $e');
      return false;
    }
  }

  // Update an existing payment
  Future<bool> updatePayment(Payment payment) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.updatePayment(payment);

      // Update payment in debt-specific list
      if (_paymentsByDebtId.containsKey(payment.debtId)) {
        final index = _paymentsByDebtId[payment.debtId]!.indexWhere(
          (p) => p.id == payment.id,
        );
        if (index != -1) {
          _paymentsByDebtId[payment.debtId]![index] = payment;
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update payment: $e');
      return false;
    }
  }

  // Delete a payment
  Future<bool> deletePayment(int id, int debtId) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.deletePayment(id);

      // Remove from debt-specific list
      if (_paymentsByDebtId.containsKey(debtId)) {
        _paymentsByDebtId[debtId]!.removeWhere((payment) => payment.id == id);
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete payment: $e');
      return false;
    }
  }

  // Get payments for a specific debt, optionally filtering for upcoming only
  List<Payment> getPaymentsForDebt(int debtId) {
    if (!_paymentsByDebtId.containsKey(debtId)) {
      return [];
    }
    return _paymentsByDebtId[debtId]!;
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }
}
