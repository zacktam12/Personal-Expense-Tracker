import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/chart_widget.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year', 'All Time'];

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

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'This Week':
        // Start of current week (Sunday)
        return DateTime(now.year, now.month, now.day - now.weekday % 7);
      case 'This Month':
        // Start of current month
        return DateTime(now.year, now.month, 1);
      case 'This Year':
        // Start of current year
        return DateTime(now.year, 1, 1);
      case 'All Time':
      default:
        // A date far in the past
        return DateTime(2000);
    }
  }

  DateTime _getEndDate() {
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final expensesNotifier = ref.read(expensesProvider.notifier);
    final startDate = _getStartDate();
    final endDate = _getEndDate();
    
    final filteredExpenses = expensesNotifier.getExpensesByDateRange(startDate, endDate);
    final categoryTotals = <String, double>{};
    
    for (final expense in filteredExpenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    // For bar chart - daily/monthly data
    final timeSeriesData = <String, double>{};
    
    if (_selectedPeriod == 'This Week' || _selectedPeriod == 'This Month') {
      // Group by day
      for (final expense in filteredExpenses) {
        final day = DateFormat('MM/dd').format(expense.date);
        timeSeriesData[day] = (timeSeriesData[day] ?? 0) + expense.amount;
      }
    } else {
      // Group by month
      for (final expense in filteredExpenses) {
        final month = DateFormat('MMM yyyy').format(expense.date);
        timeSeriesData[month] = (timeSeriesData[month] ?? 0) + expense.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'By Category'),
            Tab(text: 'Over Time'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPeriod = newValue;
                  });
                }
              },
              items: _periods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          
          // Total amount for the period
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total for $_selectedPeriod',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(
                        filteredExpenses.fold(0.0, (sum, e) => sum + e.amount)
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Charts
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Category pie chart
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ExpensePieChart(categoryTotals: categoryTotals),
                ),
                
                // Time series bar chart
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ExpenseBarChart(
                    data: timeSeriesData,
                    title: 'Expenses Over Time',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}