import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'database_service.dart';

class ExpenseService {
  final Box<Expense> _expenseBox = DatabaseService.getExpenseBox();
  final Box<Category> _categoryBox = DatabaseService.getCategoryBox();

  // CRUD operations for expenses
  Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  Expense? getExpense(String id) {
    return _expenseBox.get(id);
  }

  List<Expense> getAllExpenses() {
    return _expenseBox.values.toList();
  }

  // CRUD operations for categories
  Future<void> addCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> updateCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    // Check if it's a default category
    final category = _categoryBox.get(id);
    if (category != null && category.isDefault) {
      throw Exception("Cannot delete default category");
    }
    
    // Check if there are expenses with this category
    final expensesWithCategory = _expenseBox.values.where(
      (expense) => expense.categoryId == id
    ).toList();
    
    if (expensesWithCategory.isNotEmpty) {
      // Move expenses to "Other" category
      final otherCategory = _categoryBox.values.firstWhere(
        (cat) => cat.name == 'Other',
        orElse: () => Category.defaultCategories().last,
      );
      
      for (var expense in expensesWithCategory) {
        final updatedExpense = expense.copyWith(categoryId: otherCategory.id);
        await _expenseBox.put(expense.id, updatedExpense);
      }
    }
    
    await _categoryBox.delete(id);
  }

  Category? getCategory(String id) {
    return _categoryBox.get(id);
  }

  List<Category> getAllCategories() {
    return _categoryBox.values.toList();
  }

  // Analytics methods
  double getTotalExpenses() {
    return _expenseBox.values.fold(0, (sum, expense) => sum + expense.amount);
  }

  double getTotalExpensesForPeriod(DateTime start, DateTime end) {
    return _expenseBox.values
        .where((expense) => 
            expense.date.isAfter(start) && 
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getExpensesByCategory() {
    final result = <String, double>{};
    
    for (var category in _categoryBox.values) {
      final totalForCategory = _expenseBox.values
          .where((expense) => expense.categoryId == category.id)
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      result[category.id] = totalForCategory;
    }
    
    return result;
  }

  Map<String, double> getExpensesByCategoryForPeriod(DateTime start, DateTime end) {
    final result = <String, double>{};
    
    for (var category in _categoryBox.values) {
      final totalForCategory = _expenseBox.values
          .where((expense) => 
              expense.categoryId == category.id &&
              expense.date.isAfter(start) && 
              expense.date.isBefore(end.add(const Duration(days: 1))))
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      result[category.id] = totalForCategory;
    }
    
    return result;
  }

  List<Expense> searchExpenses(String query) {
    if (query.isEmpty) return getAllExpenses();
    
    return _expenseBox.values
        .where((expense) => 
            expense.title.toLowerCase().contains(query.toLowerCase()) ||
            (expense.notes != null && 
             expense.notes!.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  List<Expense> filterExpensesByCategory(String categoryId) {
    return _expenseBox.values
        .where((expense) => expense.categoryId == categoryId)
        .toList();
  }

  List<Expense> filterExpensesByDateRange(DateTime start, DateTime end) {
    return _expenseBox.values
        .where((expense) => 
            expense.date.isAfter(start) && 
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // Time-based analytics
  Map<DateTime, double> getDailyExpenses(DateTime start, DateTime end) {
    final result = <DateTime, double>{};
    final days = end.difference(start).inDays + 1;
    
    for (var i = 0; i < days; i++) {
      final day = DateTime(start.year, start.month, start.day + i);
      final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
      
      final expenses = _expenseBox.values
          .where((expense) => 
              expense.date.year == day.year &&
              expense.date.month == day.month &&
              expense.date.day == day.day)
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      result[day] = expenses;
    }
    
    return result;
  }

  Map<int, double> getMonthlyExpenses(int year) {
    final result = <int, double>{};
    
    for (var month = 1; month <= 12; month++) {
      final expenses = _expenseBox.values
          .where((expense) => 
              expense.date.year == year &&
              expense.date.month == month)
          .fold(0.0, (sum, expense) => sum + expense.amount);
      
      result[month] = expenses;
    }
    
    return result;
  }
}
