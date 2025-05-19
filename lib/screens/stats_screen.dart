import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/chart_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final totalExpenses = expenseProvider.getTotalExpenses();

    return Column(
      children: [
        // Summary card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Expenses',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    _buildTimeRangeDropdown(expenseProvider),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tab bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'By Category'),
            Tab(text: 'Over Time'),
          ],
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              // Category breakdown
              Padding(
                padding: EdgeInsets.all(16),
                child: ExpensePieChart(),
              ),
              
              // Time breakdown
              Padding(
                padding: EdgeInsets.all(16),
                child: ExpenseBarChart(showMonthly: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeDropdown(ExpenseProvider expenseProvider) {
    return DropdownButton<TimeRange>(
      value: expenseProvider.selectedTimeRange,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(
          value: TimeRange.day,
          child: Text('Today'),
        ),
        DropdownMenuItem(
          value: TimeRange.week,
          child: Text('This Week'),
        ),
        DropdownMenuItem(
          value: TimeRange.month,
          child: Text('This Month'),
        ),
        DropdownMenuItem(
          value: TimeRange.year,
          child: Text('This Year'),
        ),
        DropdownMenuItem(
          value: TimeRange.custom,
          child: Text('Custom'),
        ),
      ],
      onChanged: (value) {
        if (value == TimeRange.custom) {
          _showDateRangePicker(context);
        } else if (value != null) {
          expenseProvider.setTimeRange(value);
        }
      },
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final now = DateTime.now();
    final firstDay = DateTime(now.year - 1, now.month, now.day);
    final lastDay = DateTime(now.year, now.month, now.day);
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDay,
      lastDate: lastDay,
      initialDateRange: DateTimeRange(
        start: expenseProvider.customStartDate ?? DateTime(now.year, now.month, 1),
        end: expenseProvider.customEndDate ?? now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      expenseProvider.setCustomDateRange(picked.start, picked.end);
      expenseProvider.setTimeRange(TimeRange.custom);
    }
  }
}
