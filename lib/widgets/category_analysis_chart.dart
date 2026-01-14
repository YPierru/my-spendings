import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class CategoryAnalysisChart extends StatefulWidget {
  final List<Transaction> transactions;

  const CategoryAnalysisChart({
    super.key,
    required this.transactions,
  });

  @override
  State<CategoryAnalysisChart> createState() => _CategoryAnalysisChartState();
}

class _CategoryAnalysisChartState extends State<CategoryAnalysisChart> {
  String? _selectedCategory;
  int _touchedIndex = -1;

  static const List<String> _monthLabels = [
    'J', 'F', 'M', 'A', 'M', 'J',
    'J', 'A', 'S', 'O', 'N', 'D'
  ];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Fancy gradient colors
  static const Color _barColor = Color(0xFF6366F1);
  static const Color _barColorLight = Color(0xFF818CF8);
  static const Color _touchedBarColor = Color(0xFF10B981);
  static const Color _touchedBarColorLight = Color(0xFF34D399);
  static const Color _backgroundColor = Color(0xFF1E1B4B);
  static const Color _cardColor = Color(0xFF312E81);

  List<String> get _categories {
    final cats = widget.transactions
        .where((t) => t.isExpense)
        .map((t) => t.category)
        .toSet()
        .toList();
    cats.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return cats;
  }

  Map<int, double> get _monthlySpending {
    if (_selectedCategory == null) return {};

    final Map<int, double> result = {};
    for (int i = 1; i <= 12; i++) {
      result[i] = 0;
    }

    for (final t in widget.transactions) {
      if (t.category == _selectedCategory && t.isExpense) {
        result[t.date.month] = (result[t.date.month] ?? 0) + t.debit;
      }
    }
    return result;
  }

  double get _maxValue {
    final values = _monthlySpending.values;
    if (values.isEmpty) return 100;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max > 0 ? max * 1.2 : 100;
  }

  double get _totalForCategory {
    return _monthlySpending.values.fold(0.0, (sum, v) => sum + v);
  }

  double get _averageForCategory {
    final nonZeroMonths = _monthlySpending.values.where((v) => v > 0).length;
    if (nonZeroMonths == 0) return 0;
    return _totalForCategory / nonZeroMonths;
  }

  int get _peakMonth {
    final spending = _monthlySpending;
    if (spending.isEmpty) return 0;
    int peak = 1;
    double maxVal = 0;
    spending.forEach((month, value) {
      if (value > maxVal) {
        maxVal = value;
        peak = month;
      }
    });
    return peak;
  }

  @override
  void initState() {
    super.initState();
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void didUpdateWidget(CategoryAnalysisChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return const Center(child: Text('No expense data available'));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _backgroundColor,
            _backgroundColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildCategorySelector(),
          const SizedBox(height: 20),
          if (_selectedCategory != null) ...[
            _buildStatsCards(),
            const SizedBox(height: 20),
            Expanded(child: _buildChart()),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _barColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.analytics, color: _barColorLight, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spending Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Track your category over time',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _barColor.withValues(alpha: 0.3)),
      ),
      child: DropdownButton<String>(
        value: _selectedCategory,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: _cardColor,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        icon: const Icon(Icons.keyboard_arrow_down, color: _barColorLight),
        items: _categories.map((cat) => DropdownMenuItem(
          value: cat,
          child: Text(cat),
        )).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
            _touchedIndex = -1;
          });
        },
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '${_totalForCategory.toStringAsFixed(0)}€',
            Icons.account_balance_wallet,
            _barColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Average',
            '${_averageForCategory.toStringAsFixed(0)}€',
            Icons.trending_up,
            _touchedBarColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Peak',
            _peakMonth > 0 ? _monthLabels[_peakMonth - 1] : '-',
            Icons.star,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final spending = _monthlySpending;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _maxValue,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (event, response) {
            setState(() {
              if (response == null || response.spot == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = response.spot!.touchedBarGroupIndex;
            });
          },
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            tooltipMargin: 10,
            getTooltipColor: (group) => _cardColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${_monthNames[group.x]}\n',
                const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '${rod.toY.toStringAsFixed(0)}€',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final isTouched = value.toInt() == _touchedIndex;
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _monthLabels[value.toInt()],
                    style: TextStyle(
                      fontSize: 12,
                      color: isTouched ? _touchedBarColor : Colors.white54,
                      fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(12, (index) {
          final value = spending[index + 1] ?? 0;
          final isTouched = index == _touchedIndex;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: isTouched ? value + (_maxValue * 0.02) : value,
                width: isTouched ? 20 : 16,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: isTouched
                      ? [_touchedBarColorLight, _touchedBarColor]
                      : value > 0
                          ? [_barColorLight, _barColor]
                          : [Colors.white24, Colors.white12],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _maxValue,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ],
          );
        }),
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }
}
