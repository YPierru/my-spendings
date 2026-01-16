class Transaction {
  final int? id;
  final int accountId;
  final DateTime date;
  final String category;
  final String label;
  final double debit;
  final double credit;

  Transaction({
    this.id,
    required this.accountId,
    required this.date,
    required this.category,
    required this.label,
    required this.debit,
    required this.credit,
  });

  bool get isExpense => debit > 0;
  bool get isIncome => credit > 0;
  double get amount => isExpense ? debit : credit;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'account_id': accountId,
      'date': date.toIso8601String(),
      'category': category,
      'label': label,
      'debit': debit,
      'credit': credit,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      accountId: (map['account_id'] as int?) ?? 1,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      label: map['label'] as String? ?? '',
      debit: (map['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (map['credit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Transaction copyWith({
    int? id,
    int? accountId,
    DateTime? date,
    String? category,
    String? label,
    double? debit,
    double? credit,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      category: category ?? this.category,
      label: label ?? this.label,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
    );
  }

  static final Map<String, int> _frenchMonths = {
    'janv': 1,
    'fevr': 2,
    'mars': 3,
    'avr': 4,
    'mai': 5,
    'juin': 6,
    'juil': 7,
    'aout': 8,
    'sept': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  static String _normalizeMonth(String s) {
    return s
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('û', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ô', 'o')
        .replaceAll('î', 'i')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a');
  }

  static DateTime? parseDate(String dateStr, {int year = 2025}) {
    try {
      final parts = dateStr.toLowerCase().split('-');
      if (parts.length != 2) return null;

      final day = int.tryParse(parts[0]);
      if (day == null) return null;

      String monthStr = _normalizeMonth(parts[1].trim());
      int? month = _frenchMonths[monthStr];

      if (month == null) {
        for (final entry in _frenchMonths.entries) {
          if (monthStr.contains(entry.key) ||
              entry.key.contains(monthStr.replaceAll(RegExp(r'[^a-z]'), ''))) {
            month = entry.value;
            break;
          }
        }
      }

      if (month == null) return null;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  static double parseAmount(String amountStr) {
    if (amountStr.isEmpty) return 0.0;
    final cleaned = amountStr.replaceAll(',', '.').replaceAll(' ', '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
