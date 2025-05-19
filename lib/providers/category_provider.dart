import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../services/expense_service.dart';

class CategoryProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  List<Category> _categories = [];

  CategoryProvider() {
    _loadCategories();
  }

  List<Category> get categories => _categories;

  Future<void> _loadCategories() async {
    _categories = _expenseService.getAllCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _expenseService.addCategory(category);
    await _loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _expenseService.updateCategory(category);
    await _loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _expenseService.deleteCategory(id);
      await _loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Category? getCategory(String id) {
    return _expenseService.getCategory(id);
  }

  List<Category> getUserDefinedCategories() {
    return _categories.where((category) => !category.isDefault).toList();
  }

  List<Category> getDefaultCategories() {
    return _categories.where((category) => category.isDefault).toList();
  }

  // Get category by ID with fallback to "Other" if not found
  Category getCategoryById(String id) {
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => _categories.firstWhere(
        (category) => category.name == 'Other',
        orElse: () => Category.defaultCategories().last,
      ),
    );
  }
}
