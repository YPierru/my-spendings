import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/transaction.dart';

class CsvParser {
  static Future<List<Transaction>> loadTransactions() async {
    final data = await rootBundle.load('res/data.csv');
    final content = latin1.decode(data.buffer.asUint8List());

    final lines = content.split('\n');
    final transactions = <Transaction>[];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      if (line.toUpperCase().contains('NE RIEN ECRIRE')) break;

      final parts = line.split(';');
      if (parts.length < 5) continue;

      final dateStr = parts[0].trim();
      final category = parts[1].trim();
      final label = parts[2].trim();
      final debitStr = parts[3].trim();
      final creditStr = parts[4].trim();

      if (category.isEmpty) continue;

      final date = Transaction.parseDate(dateStr);
      if (date == null) continue;

      final debit = Transaction.parseAmount(debitStr);
      final credit = Transaction.parseAmount(creditStr);

      if (debit == 0 && credit == 0) continue;

      transactions.add(Transaction(
        date: date,
        category: category,
        label: label,
        debit: debit,
        credit: credit,
      ));
    }

    return transactions;
  }

  static Map<String, double> getExpensesByCategory(List<Transaction> transactions) {
    final Map<String, double> result = {};
    for (final t in transactions) {
      if (t.isExpense) {
        result[t.category] = (result[t.category] ?? 0) + t.debit;
      }
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  /// Returns balance per category (expenses - income)
  /// Positive = net expense, Negative = net income
  static Map<String, double> getBalanceByCategory(List<Transaction> transactions) {
    final Map<String, double> result = {};
    for (final t in transactions) {
      final current = result[t.category] ?? 0;
      if (t.isExpense) {
        result[t.category] = current + t.debit;
      }
      if (t.isIncome) {
        result[t.category] = current - t.credit;
      }
    }
    // Sort by absolute value descending
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => b.value.abs().compareTo(a.value.abs())),
    );
  }

  static Map<int, Map<String, double>> getMonthlyTotals(List<Transaction> transactions) {
    final Map<int, Map<String, double>> result = {};

    for (final t in transactions) {
      final month = t.date.month;
      result[month] ??= {'expenses': 0, 'income': 0};

      if (t.isExpense) {
        result[month]!['expenses'] = result[month]!['expenses']! + t.debit;
      }
      if (t.isIncome) {
        result[month]!['income'] = result[month]!['income']! + t.credit;
      }
    }

    return result;
  }

  static double getTotalExpenses(List<Transaction> transactions) {
    return transactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.debit);
  }

  static double getTotalIncome(List<Transaction> transactions) {
    return transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.credit);
  }
}
