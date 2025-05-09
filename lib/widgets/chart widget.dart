import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

enum ChartType { pie, bar, line }

class CustomChart extends ConsumerWidget {
  final bool isDetailed;
  final ChartType chartType;
  
  const CustomChart({
    Key? key,
    this.isDetailed = false,
    this.chartType = ChartType.pie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsyncValue = ref.watch(expensesProvider);
    final expensesByCategory = ref.watch(expensesByCategoryProvider);
    final expensesByDay = ref.watch(expensesByDayProvider);
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    
    return expensesAsyncValue.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return const Center(
            child: Text('No data available for this period'),
          );
        }
        
        return categoriesAsyncValue.when(
          data: (categories) {
            switch (chartType) {
              case ChartType.pie:
                return _buildPieChart(context, expensesByCategory, categories);
              case ChartType.bar:
                return _buildBarChart(context, expenses);
              case ChartType.line:
                return _buildLineChart(context, expensesByDay);
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: ${error.toString()}'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
    );
  }
  
  Widget _buildPieChart(
    BuildContext context,
    Map<String, double> expensesByCategory,
    List<categories>
  ) {
    final sections = <PieChartSectionData>[];
    
    expensesByCategory.forEach((categoryId, amount) {
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => defaultCategories[0],
      );
      
      sections.add(
        PieChartSectionData(
          color: category.color,
          value: amount,
          title: isDetailed ? '${category.name}\n${(amount / expensesByCategory.values.fold(0, (a, b) => a + b) * 100).toStringAsFixed(1)}%' : '',
          radius: isDetailed ? 80 : 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
    
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 0,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Handle touch events if needed
                },
              ),
            ),
          ),
        ),
        if (isDetailed) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: expensesByCategory.entries.map((entry) {
              final categoryId = entry.key;
              final amount = entry.value;
              final category = categories.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => defaultCategories[0],
              );
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: category.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${category.name}: \$${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildBarChart(BuildContext context, List<Expense> expenses) {
    // Group expenses by month
    final Map<String, double> monthlyTotals = {};
    
    for (final expense in expenses) {
      final monthKey = DateFormat('MMM yyyy').format(expense.date);
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }
    
    final sortedMonths = monthlyTotals.keys.toList()
      ..sort((a, b) {
        final aDate = DateFormat('MMM yyyy').parse(a);
        final bDate = DateFormat('MMM yyyy').parse(b);
        return aDate.compareTo(bDate);
      });
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyTotals.values.fold(0, (max, value) => value > max ? value : max) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = sortedMonths[groupIndex];
              return BarTooltipItem(
                '$month\n\$${rod.toY.toStringAsFixed(2)}',
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
                if (value < 0 || value >= sortedMonths.length) {
                  return const SizedBox.shrink();
                }
                final month = sortedMonths[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    month.split(' ')[0], // Just show month abbreviation
                    style: const TextStyle(fontSize: 10),
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
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          sortedMonths.length,
          (index) {
            final month = sortedMonths[index];
            final amount = monthlyTotals[month]!;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  color: Theme.of(context).colorScheme.primary,
                  width: 20,
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
    );
  }
  
  Widget _buildLineChart(BuildContext context, Map<DateTime, double> expensesByDay) {
    final sortedDays = expensesByDay.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    if (sortedDays.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final spots = <FlSpot>[];
    
    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      final amount = expensesByDay[day]!;
      spots.add(FlSpot(i.toDouble(), amount));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 100,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= sortedDays.length) {
                  return const SizedBox.shrink();
                }
                final day = sortedDays[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('E').format(day), // Weekday abbreviation
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
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: (sortedDays.length - 1).toDouble(),
        minY: 0,
        maxY: expensesByDay.values.fold(0, (max, value) => value > max ? value : max) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}