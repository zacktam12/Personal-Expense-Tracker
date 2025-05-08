import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    return await apiService.getCategories();
  } catch (e) {
    return defaultCategories;
  }
});

// Category by ID provider
final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  final categoriesAsyncValue = ref.watch(categoriesProvider);
  return categoriesAsyncValue.maybeWhen(
    data: (categories) => categories.firstWhereOrNull((c) => c.id == id),
    orElse: () => null,
  );
});

// Date range provider
final dateRangeProvider = StateProvider<DateRange>((ref) {
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
  final apiService = ref.read(apiServiceProvider);
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
    data: (expenses) =>
        expenses.fold(0, (sum, expense) => sum + expense.amount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Expenses by category provider (returns AsyncValue)
final expensesByCategoryProvider =
    Provider<AsyncValue<Map<String, double>>>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.map(
    data: (data) {
      final map = <String, double>{};
      for (final e in data.value) {
        map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
      }
      return AsyncValue.data(map);
    },
    loading: (_) => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Expenses by day provider (returns AsyncValue)
final expensesByDayProvider =
    Provider<AsyncValue<Map<DateTime, double>>>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.map(
    data: (data) {
      final map = <DateTime, double>{};
      for (final e in data.value) {
        final day = DateTime(e.date.year, e.date.month, e.date.day);
        map[day] = (map[day] ?? 0) + e.amount;
      }
      return AsyncValue.data(map);
    },
    loading: (_) => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Immutable DateRange class
@immutable
class DateRange {
  final DateTime start;
  final DateTime end;
  final DateRangeType type;

  const DateRange({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          type == other.type;

  @override
  int get hashCode => start.hashCode ^ end.hashCode ^ type.hashCode;
}

enum DateRangeType { day, week, month, year, custom }
