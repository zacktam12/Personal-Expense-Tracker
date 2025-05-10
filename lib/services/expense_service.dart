import '../models/expense.dart';
import 'database_service.dart';

class ExpenseService {
  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    await DatabaseService.expensesBox.add(expense);
  }

  // Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    final index = DatabaseService.expensesBox.values
        .toList()
        .indexWhere((e) => e.id == expense.id);

    if (index != -1) {
      await DatabaseService.expensesBox.putAt(index, expense);
    }
  }

  // Delete an expense
  Future<void> deleteExpense(String id) async {
    final index = DatabaseService.expensesBox.values
        .toList()
        .indexWhere((e) => e.id == id);

    if (index != -1) {
      await DatabaseService.expensesBox.deleteAt(index);
    }
  }

  // Get all expenses
  List<Expense> getAllExpenses() {
    return DatabaseService.expensesBox.values.toList();
  }

  // Get expenses by category
  List<Expense> getExpensesByCategory(String category) {
    return DatabaseService.expensesBox.values
        .where((expense) => expense.category == category)
        .toList();
  }

  // Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return DatabaseService.expensesBox.values
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // Get total amount spent
  double getTotalAmount() {
    return DatabaseService.expensesBox.values
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get total amount by category
  Map<String, double> getTotalByCategory() {
    final result = <String, double>{};

    for (final expense in DatabaseService.expensesBox.values) {
      if (result.containsKey(expense.category)) {
        result[expense.category] = result[expense.category]! + expense.amount;
      } else {
        result[expense.category] = expense.amount;
      }
    }

    return result;
  }
}
