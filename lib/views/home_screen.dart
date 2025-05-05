import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_tile.dart';
import '../widgets/custom_chart.dart';
import 'add_expense_screen.dart';
import 'charts_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeProvider);
    final expensesAsyncValue = ref.watch(expensesProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChartsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(ref.watch(themeProvider) ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeDateRange(ref, false),
                ),
                GestureDetector(
                  onTap: () => _showDateRangePicker(context, ref),
                  child: Text(
                    dateRange.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeDateRange(ref, true),
                ),
              ],
            ),
          ),
          
          // Total expenses card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Expenses',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '\$${totalExpenses.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Mini chart
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 150,
              child: CustomChart(isDetailed: false),
            ),
          ),
          
          // Expenses list
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Expenses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    // Show all expenses or filter
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: expensesAsyncValue.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const Center(
                    child: Text('No expenses found for this period'),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseTile(expense: expense);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _changeDateRange(WidgetRef ref, bool forward) {
    final currentRange = ref.read(dateRangeProvider);
    final type = currentRange.type;
    
    DateTime newStart, newEnd;
    
    switch (type) {
      case DateRangeType.day:
        final offset = forward ? 1 : -1;
        newStart = currentRange.start.add(Duration(days: offset));
        newEnd = currentRange.end.add(Duration(days: offset));
        break;
      case DateRangeType.week:
        final offset = forward ? 7 : -7;
        newStart = currentRange.start.add(Duration(days: offset));
        newEnd = currentRange.end.add(Duration(days: offset));
        break;
      case DateRangeType.month:
        final month = currentRange.start.month + (forward ? 1 : -1);
        final year = currentRange.start.year + (month > 12 ? 1 : (month < 1 ? -1 : 0));
        final normalizedMonth = ((month - 1) % 12) + 1;
        
        newStart = DateTime(year, normalizedMonth, 1);
        newEnd = DateTime(year, normalizedMonth + 1, 0);
        break;
      case DateRangeType.year:
        final year = currentRange.start.year + (forward ? 1 : -1);
        newStart = DateTime(year, 1, 1);
        newEnd = DateTime(year, 12, 31);
        break;
      case DateRangeType.custom:
        // For custom, we'll just shift by a month
        final days = currentRange.end.difference(currentRange.start).inDays;
        final offset = forward ? days : -days;
        newStart = currentRange.start.add(Duration(days: offset));
        newEnd = currentRange.end.add(Duration(days: offset));
        break;
    }
    
    ref.read(dateRangeProvider.notifier).state = DateRange(
      start: newStart,
      end: newEnd,
      type: type,
    );
  }
  
  void _showDateRangePicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Today'),
                onTap: () {
                  final now = DateTime.now();
                  ref.read(dateRangeProvider.notifier).state = DateRange(
                    start: DateTime(now.year, now.month, now.day),
                    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
                    type: DateRangeType.day,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('This Week'),
                onTap: () {
                  final now = DateTime.now();
                  final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
                  ref.read(dateRangeProvider.notifier).state = DateRange(
                    start: DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day),
                    end: DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day + 6, 23, 59, 59),
                    type: DateRangeType.week,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('This Month'),
                onTap: () {
                  final now = DateTime.now();
                  ref.read(dateRangeProvider.notifier).state = DateRange(
                    start: DateTime(now.year, now.month, 1),
                    end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
                    type: DateRangeType.month,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('This Year'),
                onTap: () {
                  final now = DateTime.now();
                  ref.read(dateRangeProvider.notifier).state = DateRange(
                    start: DateTime(now.year, 1, 1),
                    end: DateTime(now.year, 12, 31, 23, 59, 59),
                    type: DateRangeType.year,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Custom Range...'),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: DateTimeRange(
                      start: ref.read(dateRangeProvider).start,
                      end: ref.read(dateRangeProvider).end,
                    ),
                  );
                  
                  if (picked != null) {
                    ref.read(dateRangeProvider.notifier).state = DateRange(
                      start: picked.start,
                      end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
                      type: DateRangeType.custom,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}