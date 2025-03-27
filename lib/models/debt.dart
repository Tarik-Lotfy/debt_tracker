class Debt {
  final int? id;
  final String name;
  final String description;
  final double totalAmount;
  final double paidAmount;
  final DateTime createdAt;

  Debt({
    this.id,
    required this.name,
    required this.description,
    required this.totalAmount,
    this.paidAmount = 0.0,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Calculate remaining amount
  double get remainingAmount => totalAmount - paidAmount;

  // Calculate payment progress percentage
  double get progressPercentage =>
      totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0;

  // Check if debt is fully paid
  bool get isFullyPaid => paidAmount >= totalAmount;

  // Convert Debt to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create Debt from Map
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      totalAmount: map['totalAmount'],
      paidAmount: map['paidAmount'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create copy of Debt with updated fields
  Debt copyWith({
    int? id,
    String? name,
    String? description,
    double? totalAmount,
    double? paidAmount,
    DateTime? createdAt,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
