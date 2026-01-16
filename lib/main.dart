import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models/account.dart';
import 'models/balance.dart';
import 'models/transaction.dart';
import 'services/csv_service.dart';
import 'services/database_service.dart';
import 'widgets/account_form_dialog.dart';
import 'widgets/account_list_screen.dart';
import 'widgets/balance_dialog.dart';
import 'widgets/balance_header.dart';
import 'widgets/delete_account_dialog.dart';
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
      title: 'Spendings',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFF8F9FA),
          onSurface: const Color(0xFF1A1A1A),
          primary: const Color(0xFF1E88E5),
          onPrimary: Colors.white,
          secondary: const Color(0xFF26A69A),
          tertiary: const Color(0xFFEF5350),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF333333),
          ),
        ),
      ),
      home: const AccountManager(),
    );
  }
}

// ============ Account Manager ============
// Entry point that handles account selection and navigation to SpendingDashboard

class AccountManager extends StatefulWidget {
  const AccountManager({super.key});

  @override
  State<AccountManager> createState() => _AccountManagerState();
}

class _AccountManagerState extends State<AccountManager> {
  final DatabaseService _db = DatabaseService();
  List<AccountWithBalance> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _db.getAllAccounts();
      final accountsWithBalance = <AccountWithBalance>[];

      for (final account in accounts) {
        final balance = await _db.calculateCurrentBalanceForAccount(account.id!);
        accountsWithBalance.add(AccountWithBalance(
          account: account,
          balance: balance,
        ));
      }

      setState(() {
        _accounts = accountsWithBalance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading accounts: $e')),
        );
      }
    }
  }

  Future<void> _addAccount() async {
    final result = await showDialog<Account>(
      context: context,
      builder: (context) => const AccountFormDialog(),
    );

    if (result != null) {
      await _db.insertAccount(result);
      await _loadAccounts();
    }
  }

  Future<void> _deleteAccount(int id) async {
    final account = _accounts.firstWhere((a) => a.account.id == id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteAccountDialog(accountName: account.account.name),
    );

    if (confirmed == true) {
      await _db.deleteAccount(id);
      await _loadAccounts();
    }
  }

  void _selectAccount(Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpendingDashboard(account: account),
      ),
    ).then((_) => _loadAccounts());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AccountListScreen(
      accounts: _accounts,
      onAddAccount: _addAccount,
      onDeleteAccount: _deleteAccount,
      onSelectAccount: _selectAccount,
    );
  }
}

// ============ Spending Dashboard ============
// Shows transactions for a specific account

class SpendingDashboard extends StatefulWidget {
  final Account account;

  const SpendingDashboard({super.key, required this.account});

  @override
  State<SpendingDashboard> createState() => _SpendingDashboardState();
}

class _SpendingDashboardState extends State<SpendingDashboard> {
  final DatabaseService _db = DatabaseService();
  List<Transaction>? _transactions;
  bool _isLoading = true;
  String? _error;
  String? _selectedCategory;
  Balance? _balance;
  double _currentBalance = 0.0;

  int get _accountId => widget.account.id!;

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
    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final transactions = await _db.getTransactionsByAccount(_accountId);
      final balance = await _db.getBalanceForAccount(_accountId);
      final currentBalance = await _db.calculateCurrentBalanceForAccount(_accountId);
      setState(() {
        _transactions = transactions;
        _balance = balance;
        _currentBalance = currentBalance;
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
    // Ensure the transaction has the correct accountId
    final transactionWithAccount = transaction.copyWith(accountId: _accountId);
    await _db.insertTransaction(transactionWithAccount);
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

  Future<void> _importFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final parseResult = CsvService.parseCsv(content, accountId: _accountId);

    for (final transaction in parseResult.transactions) {
      await _db.insertTransaction(transaction);
    }

    await _loadData();

    if (mounted) {
      final imported = parseResult.transactions.length;
      final skipped = parseResult.skipped;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $imported transactions${skipped > 0 ? ' ($skipped skipped)' : ''}')),
      );
    }
  }

  Future<void> _exportToCsv() async {
    if (_transactions == null || _transactions!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    final csvContent = CsvService.generateCsv(_transactions!);

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/spendings_export.csv');
    await file.writeAsString(csvContent);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Spendings Export',
    );
  }

  void _openTransactionForm({Transaction? transaction, String? category}) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionForm(
          transaction: transaction,
          categories: _availableCategories,
          initialCategory: category,
          accountId: _accountId,
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

  Future<void> _showBalanceDialog() async {
    final result = await showDialog<Balance>(
      context: context,
      builder: (context) => BalanceDialog(
        existingBalance: _balance,
        accountId: _accountId,
      ),
    );

    if (result != null) {
      await _db.setBalanceForAccount(result);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _exportToCsv();
              } else if (value == 'import') {
                _importFromCsv();
              } else if (value == 'set_balance') {
                _showBalanceDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Text('Import CSV...'),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Text('Export CSV...'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'set_balance',
                child: Text('Set Balance...'),
              ),
            ],
          ),
        ],
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
        BalanceHeader(
          currentBalance: _currentBalance,
          balanceInfo: _balance,
        ),
        _buildFilters(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TransactionListView(
              transactions: _filteredTransactions,
              onEdit: (transaction) => _openTransactionForm(transaction: transaction),
              onDelete: (id) => _deleteTransaction(id),
              onAdd: (category) => _openTransactionForm(category: category),
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
