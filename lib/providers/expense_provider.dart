import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  final expenseService = ref.watch(expenseServiceProvider);
  return ExpensesNotifier(expenseService);
});

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final ExpenseService _expenseService;
  
  ExpensesNotifier(this._expenseService) : super([]) {
    loadExpenses();
  }
  
  Future<void> loadExpenses() async {
    state = _expenseService.getAllExpenses();
  }
  
  Future<void> addExpense(Expense expense) async {
    await _expenseService.addExpense(expense);
    state = [...state, expense];
  }
  
  Future<void> updateExpense(Expense expense) async {
    await _expenseService.updateExpense(expense);
    state = [
      for (final e in state)
        if (e.id == expense.id) expense else e,
    ];
  }
  
  Future<void> deleteExpense(String id) async {
    await _expenseService.deleteExpense(id);
    state = state.where((e) => e.id != id).toList();
  }
  
  List<Expense> getExpensesByCategory(String category) {
    return state.where((e) => e.category == category).toList();
  }
  
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return state.where((e) => 
      e.date.isAfter(start.subtract(const Duration(days: 1))) && 
      e.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }
  
  double getTotalAmount() {
    return state.fold(0, (sum, expense) => sum + expense.amount);
  }
  
  Map<String, double> getTotalByCategory() {
    final result = <String, double>{};
    
    for (final expense in state) {
      if (result.containsKey(expense.category)) {
        result[expense.category] = result[expense.category]! + expense.amount;
      } else {
        result[expense.category] = expense.amount;
      }
    }
    
    return result;
  }
}