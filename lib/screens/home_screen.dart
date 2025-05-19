import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/expense_list.dart';
import 'add_expense_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    
    final List<Widget> _pages = [
      _buildExpensesPage(expenseProvider),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? const Text('Expenses')
            : _selectedIndex == 1
                ? const Text('Statistics')
                : const Text('Settings'),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _showSearchDialog(context);
              },
            ),
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterDialog(context);
              },
            ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildExpensesPage(ExpenseProvider expenseProvider) {
    final filteredExpenses = expenseProvider.filteredExpenses;
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
        
        // Expenses list
        Expanded(
          child: ExpenseList(
            expenses: filteredExpenses,
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

  void _showSearchDialog(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Expenses'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter search term',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              expenseProvider.setSearchQuery(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                expenseProvider.setSearchQuery('');
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Expenses'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter by Category'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.maxFinite,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: expenseProvider.selectedCategoryId == null,
                        onSelected: (selected) {
                          if (selected) {
                            expenseProvider.setCategoryFilter(null);
                          }
                        },
                      ),
                      ...categoryProvider.categories.map((category) {
                        return FilterChip(
                          label: Text(category.name),
                          selected: expenseProvider.selectedCategoryId == category.id,
                          avatar: Icon(
                            category.icon,
                            color: category.color,
                            size: 16,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              expenseProvider.setCategoryFilter(category.id);
                            } else if (expenseProvider.selectedCategoryId == category.id) {
                              expenseProvider.setCategoryFilter(null);
                            }
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Filter by Time Range'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Today'),
                      selected: expenseProvider.selectedTimeRange == TimeRange.day,
                      onSelected: (selected) {
                        if (selected) {
                          expenseProvider.setTimeRange(TimeRange.day);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('This Week'),
                      selected: expenseProvider.selectedTimeRange == TimeRange.week,
                      onSelected: (selected) {
                        if (selected) {
                          expenseProvider.setTimeRange(TimeRange.week);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('This Month'),
                      selected: expenseProvider.selectedTimeRange == TimeRange.month,
                      onSelected: (selected) {
                        if (selected) {
                          expenseProvider.setTimeRange(TimeRange.month);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('This Year'),
                      selected: expenseProvider.selectedTimeRange == TimeRange.year,
                      onSelected: (selected) {
                        if (selected) {
                          expenseProvider.setTimeRange(TimeRange.year);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Custom'),
                      selected: expenseProvider.selectedTimeRange == TimeRange.custom,
                      onSelected: (selected) {
                        if (selected) {
                          Navigator.pop(context);
                          _showDateRangePicker(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                expenseProvider.setCategoryFilter(null);
                expenseProvider.setTimeRange(TimeRange.month);
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
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
