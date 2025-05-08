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
            _buildDateRangeCard(context, dateRange),
            const SizedBox(height: 24),
            _buildChartSection(
              context,
              title: 'Spending by Category',
              chart: const CustomChart(
                isDetailed: true,
                chartType: ChartType.pie,
              ),
            ),
            const SizedBox(height: 32),
            _buildChartSection(
              context,
              title: 'Monthly Comparison',
              chart: const CustomChart(
                isDetailed: true,
                chartType: ChartType.bar,
              ),
            ),
            const SizedBox(height: 32),
            _buildChartSection(
              context,
              title: 'Weekly Spending Trend',
              chart: const CustomChart(
                isDetailed: true,
                chartType: ChartType.line,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard(BuildContext context, DateRange dateRange) {
    return Card(
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
    );
  }

  Widget _buildChartSection(BuildContext context,
      {required String title, required Widget chart}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(height: 300, child: chart),
      ],
    );
  }
}
