import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    return await apiService.getCategories();
  } catch (e) {
    // If API fails, return default categories
    return defaultCategories;
  }
});

// Category by ID provider
final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  final categoriesAsyncValue = ref.watch(categoriesProvider);
  return categoriesAsyncValue.when(
    data: (categories) => categories.firstWhere(
      (category) => category.id == id,
      orElse: () => defaultCategories[0],
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});

// Date range provider
final dateRangeProvider = StateProvider<DateRange>((ref) {
  // Default to current month
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  
  return DateRange(
    start: startOfMonth,
    end: endOfMonth,
    type: DateRangeType.month,
  );
});

// Expenses provider
final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);
  
  return await apiService.getExpensesByDateRange(
    dateRange.start,
    dateRange.end,
  );
});

// Total expenses provider
final totalExpensesProvider = Provider<double>((ref) {
  final expensesAsyncValue = ref.watch(expensesProvider);
  
  return expensesAsyncValue.when(
    data: (expenses) {
      return expenses.fold(0, (sum, expense) => sum + expense.amount);
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Expenses by category provider
final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final expensesAsyncValue = ref.watch(expensesProvider);
  
  return expensesAsyncValue.when(
    data: (expenses) {
      final map = <String, double>{};
      for (final expense in expenses) {
        map[expense.categoryId] = (map[expense.categoryId] ?? 0) + expense.amount;
      }
      return map;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// Expenses by day provider (for line chart)
final expensesByDayProvider = Provider<Map<DateTime, double>>((ref) {
  final expensesAsyncValue = ref.watch(expensesProvider);
  
  return expensesAsyncValue.when(
    data: (expenses) {
      final map = <DateTime, double>{};
      for (final expense in expenses) {
        final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
        map[date] = (map[date] ?? 0) + expense.amount;
      }
      return map;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// Date range class
class DateRange {
  final DateTime start;
  final DateTime end;
  final DateRangeType type;

  DateRange({
    required this.start,
    required this.end,
    required this.type,
  });

  String get formattedRange {
    final formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  String get title {
    switch (type) {
      case DateRangeType.day:
        return DateFormat('EEEE, MMM d').format(start);
      case DateRangeType.week:
        return 'Week of ${DateFormat('MMM d').format(start)}';
      case DateRangeType.month:
        return DateFormat('MMMM yyyy').format(start);
      case DateRangeType.year:
        return DateFormat('yyyy').format(start);
      case DateRangeType.custom:
        return 'Custom Range';
    }
  }
}

enum DateRangeType { day, week, month, year, custom }