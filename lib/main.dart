import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'services/csv_parser.dart';
import 'services/database_service.dart';
import 'widgets/transaction_list_view.dart';
import 'widgets/transaction_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Spendings',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SpendingDashboard(),
    );
  }
}

class SpendingDashboard extends StatefulWidget {
  const SpendingDashboard({super.key});

  @override
  State<SpendingDashboard> createState() => _SpendingDashboardState();
}

class _SpendingDashboardState extends State<SpendingDashboard> {
  final DatabaseService _db = DatabaseService();
  List<Transaction>? _transactions;
  bool _isLoading = true;
  String? _error;
  String? _selectedCategory;

  List<Transaction> get _filteredTransactions {
    if (_transactions == null) return [];
    var filtered = _transactions!;
    if (_selectedCategory != null) {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }
    return filtered;
  }

  List<String> get _availableCategories {
    if (_transactions == null) return [];
    final categories = _transactions!.map((t) => t.category).toSet().toList();
    categories.sort();
    return categories;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Check if database is empty, if so import from CSV
      if (await _db.isEmpty()) {
        final csvTransactions = await CsvParser.loadTransactions();
        await _db.importFromCsv(csvTransactions);
      }

      final transactions = await _db.getAllTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addTransaction(Transaction transaction) async {
    await _db.insertTransaction(transaction);
    await _loadData();
  }

  Future<void> _updateTransaction(Transaction transaction) async {
    await _db.updateTransaction(transaction);
    await _loadData();
  }

  Future<void> _deleteTransaction(int id) async {
    await _db.deleteTransaction(id);
    await _loadData();
  }

  void _openTransactionForm({Transaction? transaction}) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionForm(
          transaction: transaction,
          categories: _availableCategories,
        ),
      ),
    );

    if (result != null) {
      if (transaction != null) {
        await _updateTransaction(result);
      } else {
        await _addTransaction(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Spendings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTransactionForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TransactionListView(
              transactions: _filteredTransactions,
              onEdit: (transaction) => _openTransactionForm(transaction: transaction),
              onDelete: (id) => _deleteTransaction(id),
              onAdd: () => _openTransactionForm(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        child: DropdownButton<String?>(
          value: _selectedCategory,
          isExpanded: true,
          underline: const SizedBox(),
          isDense: true,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All categories'),
            ),
            ..._availableCategories.map((cat) => DropdownMenuItem<String?>(
                  value: cat,
                  child: Text(cat, overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ),
    );
  }
}
