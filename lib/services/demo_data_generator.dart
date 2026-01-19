import 'dart:math';
import '../models/account.dart';
import '../models/balance.dart';
import '../models/transaction.dart';

/// Generates demo data for demonstration purposes.
/// This allows users to show the app without revealing real financial data.
class DemoDataGenerator {
  static final Random _random = Random();

  /// Demo account definitions
  static const List<String> _demoAccountNames = [
    'Personal',
    'Joint Account',
    'Savings',
  ];

  /// Expense categories with typical labels and amount ranges
  static const Map<String, _CategoryConfig> _expenseCategories = {
    'Groceries': _CategoryConfig(
      labels: ['Carrefour', 'Lidl', 'Market', 'Supermarket', 'Aldi'],
      minAmount: 15.0,
      maxAmount: 120.0,
    ),
    'Transport': _CategoryConfig(
      labels: ['Metro', 'Uber', 'Gas Station', 'Bus', 'Taxi'],
      minAmount: 5.0,
      maxAmount: 80.0,
    ),
    'Entertainment': _CategoryConfig(
      labels: ['Netflix', 'Cinema', 'Spotify', 'Concert', 'Games'],
      minAmount: 10.0,
      maxAmount: 50.0,
    ),
    'Restaurants': _CategoryConfig(
      labels: ['Lunch', 'Dinner Out', 'Coffee', 'Fast Food', 'Takeaway'],
      minAmount: 8.0,
      maxAmount: 60.0,
    ),
    'Shopping': _CategoryConfig(
      labels: ['Amazon', 'Clothing', 'Electronics', 'Books', 'Gifts'],
      minAmount: 15.0,
      maxAmount: 200.0,
    ),
    'Utilities': _CategoryConfig(
      labels: ['Electricity', 'Internet', 'Phone', 'Water', 'Gas'],
      minAmount: 30.0,
      maxAmount: 150.0,
    ),
    'Subscriptions': _CategoryConfig(
      labels: ['Gym', 'Cloud Storage', 'Magazine', 'Software', 'Streaming'],
      minAmount: 10.0,
      maxAmount: 50.0,
    ),
  };

  /// Income categories with typical labels and amount ranges
  static const Map<String, _CategoryConfig> _incomeCategories = {
    'Salary': _CategoryConfig(
      labels: ['Monthly Salary', 'Paycheck'],
      minAmount: 2500.0,
      maxAmount: 4500.0,
    ),
    'Freelance': _CategoryConfig(
      labels: ['Freelance Work', 'Side Project', 'Consulting'],
      minAmount: 200.0,
      maxAmount: 1000.0,
    ),
    'Refund': _CategoryConfig(
      labels: ['Tax Refund', 'Return', 'Reimbursement'],
      minAmount: 20.0,
      maxAmount: 200.0,
    ),
  };

  /// Generates demo accounts (without IDs - they'll be assigned by the database)
  static List<Account> generateDemoAccounts() {
    return _demoAccountNames
        .map((name) => Account(
              name: name,
              createdAt: DateTime.now(),
            ))
        .toList();
  }

  /// Generates transactions for a specific account
  /// [accountId] - The ID of the account to generate transactions for
  /// [transactionCount] - Number of transactions to generate (default 50-80)
  static List<Transaction> generateTransactionsForAccount(
    int accountId, {
    int? transactionCount,
  }) {
    final count = transactionCount ?? (50 + _random.nextInt(31)); // 50-80
    final transactions = <Transaction>[];
    final now = DateTime.now();

    for (var i = 0; i < count; i++) {
      // 85% expenses, 15% income
      final isExpense = _random.nextDouble() < 0.85;

      final transaction = isExpense
          ? _generateExpenseTransaction(accountId, now)
          : _generateIncomeTransaction(accountId, now);

      transactions.add(transaction);
    }

    // Sort by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  static Transaction _generateExpenseTransaction(int accountId, DateTime now) {
    final categories = _expenseCategories.keys.toList();
    final category = categories[_random.nextInt(categories.length)];
    final config = _expenseCategories[category]!;

    final label = config.labels[_random.nextInt(config.labels.length)];
    final amount = _generateAmount(config.minAmount, config.maxAmount);
    final date = _generateRandomDate(now);

    return Transaction(
      accountId: accountId,
      date: date,
      category: category,
      label: label,
      debit: amount,
      credit: 0.0,
    );
  }

  static Transaction _generateIncomeTransaction(int accountId, DateTime now) {
    final categories = _incomeCategories.keys.toList();
    final category = categories[_random.nextInt(categories.length)];
    final config = _incomeCategories[category]!;

    final label = config.labels[_random.nextInt(config.labels.length)];
    final amount = _generateAmount(config.minAmount, config.maxAmount);
    final date = _generateRandomDate(now);

    return Transaction(
      accountId: accountId,
      date: date,
      category: category,
      label: label,
      debit: 0.0,
      credit: amount,
    );
  }

  /// Generates a random amount between min and max, rounded to 2 decimals
  static double _generateAmount(double min, double max) {
    final amount = min + _random.nextDouble() * (max - min);
    return (amount * 100).round() / 100;
  }

  /// Generates a random date within the last 6 months
  static DateTime _generateRandomDate(DateTime now) {
    final daysAgo = _random.nextInt(180); // 0-179 days ago
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysAgo));
  }

  /// Generates a balance for a specific account
  static Balance generateBalanceForAccount(int accountId) {
    // Set effective date to 6 months ago
    final now = DateTime.now();
    final effectiveDate = DateTime(now.year, now.month - 6, 1);

    // Random initial balance between 1000 and 10000
    final amount = 1000.0 + _random.nextDouble() * 9000.0;
    final roundedAmount = (amount * 100).round() / 100;

    return Balance(
      accountId: accountId,
      amount: roundedAmount,
      date: effectiveDate,
      createdAt: DateTime.now(),
    );
  }
}

/// Configuration for a category's transaction generation
class _CategoryConfig {
  final List<String> labels;
  final double minAmount;
  final double maxAmount;

  const _CategoryConfig({
    required this.labels,
    required this.minAmount,
    required this.maxAmount,
  });
}
