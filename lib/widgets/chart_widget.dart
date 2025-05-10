import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class ExpensePieChart extends ConsumerWidget {
  final Map<String, double> categoryTotals;

  const ExpensePieChart({
    Key? key,
    required this.categoryTotals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final totalAmount = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _createPieSections(categories),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Handle touch events if needed
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: categoryTotals.entries.map((entry) {
            final category = categories.firstWhere(
              (c) => c.name == entry.key,
              orElse: () => Category(
                name: entry.key,
                icon: 'more_horiz',
                color: '808080',
              ),
            );
            
            final percentage = totalAmount > 0 
                ? (entry.value / totalAmount * 100).toStringAsFixed(1) 
                : '0.0';
                
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: category.colorValue,
                ),
                const SizedBox(width: 4),
                Text(
                  '${category.name}: $percentage%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _createPieSections(List<Category> categories) {
    return categoryTotals.entries.map((entry) {
      final category = categories.firstWhere(
        (c) => c.name == entry.key,
        orElse: () => Category(
          name: entry.key,
          icon: 'more_horiz',
          color: '808080',
        ),
      );
      
      final totalAmount = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
      final percentage = totalAmount > 0 ? entry.value / totalAmount * 100 : 0.0;
      
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: category.colorValue,
        radius: 100,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();
  }
}

class ExpenseBarChart extends ConsumerWidget {
  final Map<String, double> data;
  final String title;

  const ExpenseBarChart({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = data.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final key = data.keys.elementAt(groupIndex);
                    final value = data.values.elementAt(groupIndex);
                    return BarTooltipItem(
                      '\$${value.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white),
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
                      if (value < 0 || value >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final key = data.keys.elementAt(value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          key,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.entries.map((entry) {
                return BarChartGroupData(
                  x: data.keys.toList().indexOf(entry.key),
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: Colors.blue,
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}