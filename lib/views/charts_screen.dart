import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../widgets/custom_chart.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Period',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      dateRange.formattedRange,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Category breakdown (pie chart)
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 300,
              child: CustomChart(
                isDetailed: true,
                chartType: ChartType.pie,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Monthly comparison (bar chart)
            Text(
              'Monthly Comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 300,
              child: CustomChart(
                isDetailed: true,
                chartType: ChartType.bar,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Weekly trend (line chart)
            Text(
              'Weekly Spending Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 300,
              child: CustomChart(
                isDetailed: true,
                chartType: ChartType.line,
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}