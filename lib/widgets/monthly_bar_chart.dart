import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyBarChart extends StatelessWidget {
  final Map<int, Map<String, double>> monthlyTotals;

  const MonthlyBarChart({super.key, required this.monthlyTotals});

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final maxValue = monthlyTotals.values.fold(0.0, (max, data) {
      final expenses = data['expenses'] ?? 0;
      final income = data['income'] ?? 0;
      return [max, expenses, income].reduce((a, b) => a > b ? a : b);
    });

    return Column(
      children: [
        const Text(
          'Monthly Expenses vs Income',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(Colors.red.shade400, 'Expenses'),
            const SizedBox(width: 24),
            _legendItem(Colors.green.shade400, 'Income'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 8, bottom: 8),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.1,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = _monthNames[group.x];
                      final type = rodIndex == 0 ? 'Expenses' : 'Income';
                      return BarTooltipItem(
                        '$month\n$type: ${rod.toY.toStringAsFixed(0)}€',
                        const TextStyle(color: Colors.white, fontSize: 12),
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
                        if (value < 0 || value >= 12) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _monthNames[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxValue / 5,
                  drawVerticalLine: false,
                ),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(12, (month) {
      final data = monthlyTotals[month + 1] ?? {'expenses': 0.0, 'income': 0.0};
      final expenses = data['expenses'] ?? 0.0;
      final income = data['income'] ?? 0.0;

      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: expenses,
            color: Colors.red.shade400,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
          BarChartRodData(
            toY: income,
            color: Colors.green.shade400,
            width: 10,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      );
    });
  }
}
