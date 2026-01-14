import '../models/transaction.dart';

class CsvService {
  static const String header = 'Date;Category;Label;Amount';

  /// Generates CSV content from a list of transactions
  /// Format: Date;Category;Label;Amount
  /// Date format: DD/MM/YYYY
  /// Amount: negative for expenses, positive for income
  static String generateCsv(List<Transaction> transactions) {
    final buffer = StringBuffer();
    buffer.writeln(header);

    for (final t in transactions) {
      final date = '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}';
      final amount = t.isExpense ? -t.debit : t.credit;
      final label = t.label.replaceAll(';', ',');
      final category = t.category.replaceAll(';', ',');
      buffer.writeln('$date;$category;$label;${amount.toStringAsFixed(2)}');
    }

    return buffer.toString();
  }

  /// Parses CSV content and returns a list of transactions
  /// Expected format: Date;Category;Label;Amount
  /// Date format: DD/MM/YYYY
  /// Amount: negative for expenses, positive for income
  /// Returns a record with (transactions, skippedCount)
  static ({List<Transaction> transactions, int skipped}) parseCsv(String content) {
    final lines = content.split('\n');
    final transactions = <Transaction>[];
    int skipped = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Skip header line
      if (i == 0 && line.toLowerCase().contains('date') && line.toLowerCase().contains('category')) {
        continue;
      }

      final transaction = parseLine(line);
      if (transaction != null) {
        transactions.add(transaction);
      } else {
        skipped++;
      }
    }

    return (transactions: transactions, skipped: skipped);
  }

  /// Parses a single CSV line into a Transaction
  /// Returns null if the line cannot be parsed
  static Transaction? parseLine(String line) {
    final parts = line.split(';');
    if (parts.length < 4) return null;

    try {
      // Parse date (DD/MM/YYYY)
      final dateParts = parts[0].split('/');
      if (dateParts.length != 3) return null;

      final date = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      final category = parts[1].trim();
      final label = parts[2].trim();
      final amount = double.parse(parts[3].trim().replaceAll(',', '.'));

      return Transaction(
        date: date,
        category: category,
        label: label,
        debit: amount < 0 ? -amount : 0,
        credit: amount > 0 ? amount : 0,
      );
    } catch (e) {
      return null;
    }
  }
}
