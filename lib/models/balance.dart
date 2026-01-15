class Balance {
  final int? id;
  final double amount;
  final DateTime date;
  final DateTime createdAt;

  Balance({
    this.id,
    required this.amount,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Balance.fromMap(Map<String, dynamic> map) {
    return Balance(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Balance copyWith({
    int? id,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Balance(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
