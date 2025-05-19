import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final expensesByCategory = expenseProvider.getExpensesByCategory();
    
    // Filter out categories with zero expenses
    final filteredExpenses = expensesByCategory.entries
        .where((entry) => entry.value > 0)
        .toList();
    
    if (filteredExpenses.isEmpty) {
      return const Center(
        child: Text('No expenses to display'),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: filteredExpenses.map((entry) {
                final category = categoryProvider.getCategoryById(entry.key);
                return PieChartSectionData(
                  color: category.color,
                  value: entry.value,
                  title: '${(entry.value / expenseProvider.getTotalExpenses() * 100).toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: filteredExpenses.map((entry) {
            final category = categoryProvider.getCategoryById(entry.key);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${category.name}: \$${entry.value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ExpenseBarChart extends StatelessWidget {
  final bool showMonthly;

  const ExpenseBarChart({
    Key? key,
    this.showMonthly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    
    if (showMonthly) {
      final currentYear = DateTime.now().year;
      final monthlyExpenses = expenseProvider.getMonthlyExpenses(currentYear);
      
      return _buildMonthlyBarChart(context, monthlyExpenses, currentYear);
    } else {
      final dailyExpenses = expenseProvider.getDailyExpenses();
      
      return _buildDailyBarChart(context, dailyExpenses);
    }
  }

  Widget _buildDailyBarChart(BuildContext context, Map<DateTime, double> dailyExpenses) {
    if (dailyExpenses.isEmpty) {
      return const Center(
        child: Text('No expenses to display'),
      );
    }

    // Sort dates
    final sortedDates = dailyExpenses.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    // Get the max value for the y-axis
    final maxY = dailyExpenses.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Theme.of(context).colorScheme.surface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final date = sortedDates[groupIndex];
                  final amount = dailyExpenses[date]!;
                  return BarTooltipItem(
                    '${DateFormat.MMMd().format(date)}\n\$${amount.toStringAsFixed(2)}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
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
                    if (value < 0 || value >= sortedDates.length) {
                      return const SizedBox();
                    }
                    final date = sortedDates[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat.MMMd().format(date),
                        style: Theme.of(context).textTheme.bodySmall,
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
                      style: Theme.of(context).textTheme.bodySmall,
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
            gridData: FlGridData(
              show: true,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
              drawVerticalLine: false,
            ),
            barGroups: List.generate(
              sortedDates.length,
              (index) {
                final date = sortedDates[index];
                final amount = dailyExpenses[date]!;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: amount,
                      color: Theme.of(context).colorScheme.primary,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyBarChart(BuildContext context, Map<int, double> monthlyExpenses, int year) {
    if (monthlyExpenses.isEmpty) {
      return const Center(
        child: Text('No expenses to display'),
      );
    }

    // Get the max value for the y-axis
    final maxY = monthlyExpenses.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Theme.of(context).colorScheme.surface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = group.x + 1;
                  final amount = monthlyExpenses[month] ?? 0;
                  return BarTooltipItem(
                    '${DateFormat.MMMM().format(DateTime(year, month))}\n\$${amount.toStringAsFixed(2)}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
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
                    final month = value.toInt() + 1;
                    if (month < 1 || month > 12) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat.MMM().format(DateTime(year, month)),
                        style: Theme.of(context).textTheme.bodySmall,
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
                      style: Theme.of(context).textTheme.bodySmall,
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
            gridData: FlGridData(
              show: true,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
              drawVerticalLine: false,
            ),
            barGroups: List.generate(
              12,
              (index) {
                final month = index + 1;
                final amount = monthlyExpenses[month] ?? 0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: amount,
                      color: Theme.of(context).colorScheme.primary,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
