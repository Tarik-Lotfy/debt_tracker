class Payment {
  final int? id;
  final int debtId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;

  Payment({
    this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.notes,
  });

  // Convert Payment to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtId': debtId,
      'amount': amount,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  // Create Payment from Map
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      debtId: map['debtId'],
      amount: map['amount'],
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['paymentDate']),
      notes: map['notes'],
    );
  }

  // Create copy of Payment with updated fields
  Payment copyWith({
    int? id,
    int? debtId,
    double? amount,
    DateTime? paymentDate,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
    );
  }
}
