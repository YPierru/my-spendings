import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> expensesByCategory;
  final ValueChanged<String>? onCategorySelected;

  const CategoryPieChart({
    super.key,
    required this.expensesByCategory,
    this.onCategorySelected,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFFF44336),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFFEB3B),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFE91E63),
    Color(0xFF3F51B5),
    Color(0xFF009688),
    Color(0xFFCDDC39),
    Color(0xFFFF5722),
    Color(0xFF673AB7),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = widget.expensesByCategory.entries.toList();
    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Column(
      children: [
        const Text(
          'Expenses by Category',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });

                  if (event is FlTapUpEvent &&
                      pieTouchResponse?.touchedSection != null) {
                    final index =
                        pieTouchResponse!.touchedSection!.touchedSectionIndex;
                    if (index >= 0 && index < entries.length) {
                      widget.onCategorySelected?.call(entries[index].key);
                    }
                  }
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildSections(entries, total),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildLegend(entries, total),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(
      List<MapEntry<String, double>> entries, double total) {
    return entries.asMap().entries.map((e) {
      final index = e.key;
      final entry = e.value;
      final isTouched = index == touchedIndex;
      final percentage = (entry.value / total) * 100;

      return PieChartSectionData(
        color: _colors[index % _colors.length],
        value: entry.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<MapEntry<String, double>> entries, double total) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final percentage = (entry.value / total) * 100;

        return InkWell(
          onTap: () => widget.onCategorySelected?.call(entry.key),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _colors[index % _colors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${entry.value.toStringAsFixed(0)}€ (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
