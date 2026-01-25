import 'package:flutter/material.dart';
import '../models/transaction.dart';

enum ViewMode { monthlyGrouped, yearlyGrouped, flat }

class TransactionListView extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(Transaction)? onEdit;
  final Function(int)? onDelete;
  final void Function(String? category)? onAdd;

  const TransactionListView({
    super.key,
    required this.transactions,
    this.onEdit,
    this.onDelete,
    this.onAdd,
  });

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  String _filter = 'all';
  String _searchQuery = '';
  String _currentMonth = '';
  String _currentPeriod = '';
  bool _showMonthBadge = false;
  ViewMode _viewMode = ViewMode.monthlyGrouped;
  final ScrollController _scrollController = ScrollController();

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCurrentMonth());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _initCurrentMonth() {
    if (_filteredList.isNotEmpty) {
      final t = _filteredList.first;
      setState(() {
        _currentMonth = _formatMonthHeader(
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}',
        );
      });
    }
  }

  void _onScroll() {
    if (!_showMonthBadge) {
      setState(() => _showMonthBadge = true);
    }
    _hideBadgeAfterDelay();
  }

  void _hideBadgeAfterDelay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_scrollController.position.isScrollingNotifier.value) {
        setState(() => _showMonthBadge = false);
      }
    });
  }

  List<Transaction> get _filteredList {
    var list = widget.transactions;

    if (_filter == 'expenses') {
      list = list.where((t) => t.isExpense).toList();
    } else if (_filter == 'income') {
      list = list.where((t) => t.isIncome).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));

    return list;
  }

  Map<String, Map<String, Map<String, double>>> get _groupedByCategory {
    final result = <String, Map<String, Map<String, double>>>{};

    for (final t in _filteredList) {
      final monthKey = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';

      result.putIfAbsent(monthKey, () => {});
      result[monthKey]!.putIfAbsent(t.category, () => {'expenses': 0.0, 'income': 0.0});

      if (t.isExpense) {
        result[monthKey]![t.category]!['expenses'] =
            result[monthKey]![t.category]!['expenses']! + t.amount;
      } else if (t.isIncome) {
        result[monthKey]![t.category]!['income'] =
            result[monthKey]![t.category]!['income']! + t.amount;
      }
    }

    return result;
  }

  Map<String, Map<String, Map<String, double>>> get _groupedByYear {
    final result = <String, Map<String, Map<String, double>>>{};

    for (final t in _filteredList) {
      final yearKey = '${t.date.year}';

      result.putIfAbsent(yearKey, () => {});
      result[yearKey]!.putIfAbsent(t.category, () => {'expenses': 0.0, 'income': 0.0});

      if (t.isExpense) {
        result[yearKey]![t.category]!['expenses'] =
            result[yearKey]![t.category]!['expenses']! + t.amount;
      } else if (t.isIncome) {
        result[yearKey]![t.category]!['income'] =
            result[yearKey]![t.category]!['income']! + t.amount;
      }
    }

    return result;
  }

  String _formatMonthHeader(String key) {
    final parts = key.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    return '${_monthNames[month - 1]} $year';
  }

  String _formatLastTransactionDate() {
    if (widget.transactions.isEmpty) return '-';
    final lastTransaction = widget.transactions.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );
    final d = lastTransaction.date;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  List<Transaction> _getTransactionsForCategoryAndMonth(String category, String monthKey) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return _filteredList
        .where((t) =>
            t.category == category &&
            t.date.year == year &&
            t.date.month == month)
        .toList();
  }

  List<Transaction> _getTransactionsForCategoryAndYear(String category, String yearKey) {
    final year = int.parse(yearKey);

    return _filteredList
        .where((t) =>
            t.category == category &&
            t.date.year == year)
        .toList();
  }

  void _showCategoryTransactions(String category, String monthKey) {
    final transactions = _getTransactionsForCategoryAndMonth(category, monthKey);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: widget.onAdd != null
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    widget.onAdd!(category);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$category - ${_formatMonthHeader(monthKey)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 40,
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 36,
                                color: Colors.grey.shade400,
                              ),
                              Positioned(
                                bottom: 4,
                                child: Text(
                                  '${t.date.day}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          t.label.isNotEmpty ? t.label : category,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${t.isExpense ? '-' : '+'}${t.amount.toStringAsFixed(2)}€',
                              style: TextStyle(
                                color: t.isExpense ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.onEdit != null)
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  widget.onEdit!(t);
                                },
                                color: Colors.grey.shade600,
                              ),
                            if (widget.onDelete != null)
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: () => _confirmDeleteInSheet(t, sheetContext),
                                color: Colors.red.shade400,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryTransactionsForYear(String category, String yearKey) {
    final transactions = _getTransactionsForCategoryAndYear(category, yearKey);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: widget.onAdd != null
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    widget.onAdd!(category);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$category - $yearKey',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 40,
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 36,
                                color: Colors.grey.shade400,
                              ),
                              Positioned(
                                bottom: 4,
                                child: Text(
                                  '${t.date.day}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          t.label.isNotEmpty ? t.label : category,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          _formatMonthHeader('${t.date.year}-${t.date.month.toString().padLeft(2, '0')}'),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${t.isExpense ? '-' : '+'}${t.amount.toStringAsFixed(2)}€',
                              style: TextStyle(
                                color: t.isExpense ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.onEdit != null)
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  widget.onEdit!(t);
                                },
                                color: Colors.grey.shade600,
                              ),
                            if (widget.onDelete != null)
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: () => _confirmDeleteInSheet(t, sheetContext),
                                color: Colors.red.shade400,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteInSheet(Transaction t, BuildContext sheetContext) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${t.category}${t.label.isNotEmpty ? ' - ${t.label}' : ''}" for ${t.amount.toStringAsFixed(2)}€?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && t.id != null && widget.onDelete != null) {
      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
      widget.onDelete!(t.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SizedBox(
            height: 36,
            child: TextField(
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _filterChip('All', 'all'),
              const SizedBox(width: 6),
              _filterChip('Expenses', 'expenses'),
              const SizedBox(width: 6),
              _filterChip('Income', 'income'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _viewModeChip('Month', ViewMode.monthlyGrouped, Icons.calendar_view_month),
              const SizedBox(width: 6),
              _viewModeChip('Year', ViewMode.yearlyGrouped, Icons.calendar_today),
              const SizedBox(width: 6),
              _viewModeChip('List', ViewMode.flat, Icons.list),
            ],
          ),
        ),
        if (widget.transactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Last transaction date: ${_formatLastTransactionDate()}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        Expanded(
          child: _filteredList.isEmpty
              ? const Center(child: Text('No transactions found'))
              : Stack(
                  children: [
                    _buildListForCurrentMode(),
                    if (_showMonthBadge && _viewMode != ViewMode.flat)
                      Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _showMonthBadge ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _viewMode == ViewMode.yearlyGrouped ? _currentPeriod : _currentMonth,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget _viewModeChip(String label, ViewMode mode, IconData icon) {
    final isSelected = _viewMode == mode;
    return FilterChip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => setState(() {
        _viewMode = mode;
        _scrollController.jumpTo(0);
      }),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget _buildListForCurrentMode() {
    switch (_viewMode) {
      case ViewMode.monthlyGrouped:
        return _buildGroupedList();
      case ViewMode.yearlyGrouped:
        return _buildYearlyGroupedList();
      case ViewMode.flat:
        return _buildFlatList();
    }
  }

  Widget _buildGroupedList() {
    final grouped = _groupedByCategory;
    final monthKeys = grouped.keys.toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _updateCurrentMonthFromGroupedScroll(monthKeys);
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: monthKeys.length,
        itemBuilder: (context, monthIndex) {
          final monthKey = monthKeys[monthIndex];
          final categories = grouped[monthKey]!;
          final categoryNames = categories.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 32,
                margin: EdgeInsets.only(top: monthIndex > 0 ? 8 : 0),
                color: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatMonthHeader(monthKey),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              ...categoryNames.map((category) => _buildCategoryItem(
                    category,
                    categories[category]!['expenses']!,
                    categories[category]!['income']!,
                    monthKey,
                  )),
            ],
          );
        },
      ),
    );
  }

  void _updateCurrentMonthFromGroupedScroll(List<String> monthKeys) {
    if (monthKeys.isEmpty) return;

    final grouped = _groupedByCategory;
    final scrollOffset = _scrollController.offset;

    // Calculate cumulative heights to find current month
    double cumulativeHeight = 0;
    for (final monthKey in monthKeys) {
      final categoryCount = grouped[monthKey]!.length;
      final sectionHeight = 32.0 + (categoryCount * 50.0) + 8.0; // header + items + margin

      if (scrollOffset < cumulativeHeight + sectionHeight) {
        final newMonth = _formatMonthHeader(monthKey);
        if (newMonth != _currentMonth) {
          setState(() => _currentMonth = newMonth);
        }
        return;
      }
      cumulativeHeight += sectionHeight;
    }
  }

  Widget _buildYearlyGroupedList() {
    final grouped = _groupedByYear;
    final yearKeys = grouped.keys.toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _updateCurrentPeriodFromYearlyScroll(yearKeys);
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: yearKeys.length,
        itemBuilder: (context, yearIndex) {
          final yearKey = yearKeys[yearIndex];
          final categories = grouped[yearKey]!;
          final categoryNames = categories.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 32,
                margin: EdgeInsets.only(top: yearIndex > 0 ? 8 : 0),
                color: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  yearKey,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              ...categoryNames.map((category) => _buildCategoryItemForYear(
                    category,
                    categories[category]!['expenses']!,
                    categories[category]!['income']!,
                    yearKey,
                  )),
            ],
          );
        },
      ),
    );
  }

  void _updateCurrentPeriodFromYearlyScroll(List<String> yearKeys) {
    if (yearKeys.isEmpty) return;

    final grouped = _groupedByYear;
    final scrollOffset = _scrollController.offset;

    // Calculate cumulative heights to find current year
    double cumulativeHeight = 0;
    for (final yearKey in yearKeys) {
      final categoryCount = grouped[yearKey]!.length;
      final sectionHeight = 32.0 + (categoryCount * 50.0) + 8.0; // header + items + margin

      if (scrollOffset < cumulativeHeight + sectionHeight) {
        if (yearKey != _currentPeriod) {
          setState(() => _currentPeriod = yearKey);
        }
        return;
      }
      cumulativeHeight += sectionHeight;
    }
  }

  Widget _buildCategoryItemForYear(String category, double expenses, double income, String yearKey) {
    return InkWell(
      onTap: () => _showCategoryTransactionsForYear(category, yearKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (expenses > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-${expenses.toStringAsFixed(2)}€',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            if (income > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+${income.toStringAsFixed(2)}€',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category, double expenses, double income, String monthKey) {
    return InkWell(
      onTap: () => _showCategoryTransactions(category, monthKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (expenses > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-${expenses.toStringAsFixed(2)}€',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            if (income > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+${income.toStringAsFixed(2)}€',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatList() {
    final transactions = _filteredList;

    return ListView.builder(
      controller: _scrollController,
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        return _buildFlatTransactionItem(t);
      },
    );
  }

  Widget _buildFlatTransactionItem(Transaction t) {
    return InkWell(
      onTap: () => _showTransactionActions(t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (t.label.isNotEmpty)
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '${t.isExpense ? '-' : '+'}${t.amount.toStringAsFixed(2)}€',
              style: TextStyle(
                color: t.isExpense ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionActions(Transaction t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            if (t.label.isNotEmpty)
              Text(
                t.label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${t.isExpense ? '-' : '+'}${t.amount.toStringAsFixed(2)}€',
                  style: TextStyle(
                    color: t.isExpense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.onEdit != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      widget.onEdit!(t);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                if (widget.onDelete != null)
                  ElevatedButton.icon(
                    onPressed: () => _confirmDeleteInSheet(t, sheetContext),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
