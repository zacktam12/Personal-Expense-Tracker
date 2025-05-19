import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

enum TimeRange { day, week, month, year, custom }

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  String _searchQuery = '';
  String? _selectedCategoryId;
  TimeRange _selectedTimeRange = TimeRange.month;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  ExpenseProvider() {
    _loadExpenses();
  }

  List<Expense> get expenses => _expenses;
  List<Expense> get filteredExpenses => _filteredExpenses;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  TimeRange get selectedTimeRange => _selectedTimeRange;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;

  Future<void> _loadExpenses() async {
    _expenses = _expenseService.getAllExpenses();
    _applyFilters();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseService.addExpense(expense);
    await _loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseService.updateExpense(expense);
    await _loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.deleteExpense(id);
    await _loadExpenses();
  }

  Expense? getExpense(String id) {
    return _expenseService.getExpense(id);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void setTimeRange(TimeRange timeRange) {
    _selectedTimeRange = timeRange;
    _applyFilters();
    notifyListeners();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    _customStartDate = start;
    _customEndDate = end;
    if (_selectedTimeRange == TimeRange.custom) {
      _applyFilters();
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredExpenses = List.from(_expenses);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredExpenses = _filteredExpenses
          .where((expense) =>
              expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (expense.notes != null &&
                  expense.notes!.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    // Apply category filter
    if (_selectedCategoryId != null) {
      _filteredExpenses = _filteredExpenses
          .where((expense) => expense.categoryId == _selectedCategoryId)
          .toList();
    }

    // Apply time range filter
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedTimeRange) {
      case TimeRange.day:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimeRange.week:
        // Start from the beginning of the week (Monday)
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case TimeRange.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case TimeRange.year:
        startDate = DateTime(now.year, 1, 1);
        break;
      case TimeRange.custom:
        if (_customStartDate != null && _customEndDate != null) {
          startDate = _customStartDate!;
          endDate = DateTime(
            _customEndDate!.year,
            _customEndDate!.month,
            _customEndDate!.day,
            23,
            59,
            59,
          );
        } else {
          // Default to month if custom dates are not set
          startDate = DateTime(now.year, now.month, 1);
        }
        break;
    }

    _filteredExpenses = _filteredExpenses
        .where((expense) =>
            expense.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            expense.date.isBefore(endDate.add(const Duration(seconds: 1))))
        .toList();

    // Sort by date (newest first)
    _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
  }

  // Analytics methods
  double getTotalExpenses() {
    return _filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getExpensesByCategory() {
    final result = <String, double>{};
    
    for (var expense in _filteredExpenses) {
      result[expense.categoryId] = (result[expense.categoryId] ?? 0) + expense.amount;
    }
    
    return result;
  }

  Map<DateTime, double> getDailyExpenses() {
    final result = <DateTime, double>{};
    
    for (var expense in _filteredExpenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      result[date] = (result[date] ?? 0) + expense.amount;
    }
    
    return result;
  }

  Map<int, double> getMonthlyExpenses(int year) {
    final result = <int, double>{};
    
    for (var month = 1; month <= 12; month++) {
      final expenses = _filteredExpenses
          .where((expense) => 
              expense.date.year == year &&
              expense.date.month == month)
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      result[month] = expenses;
    }
    
    return result;
  }
}
