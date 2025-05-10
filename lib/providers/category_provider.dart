import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/database_service.dart';

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([]) {
    loadCategories();
  }
  
  void loadCategories() {
    state = DatabaseService.categoriesBox.values.toList();
  }
  
  Future<void> addCategory(Category category) async {
    await DatabaseService.categoriesBox.add(category);
    state = [...state, category];
  }
  
  Future<void> updateCategory(int index, Category category) async {
    await DatabaseService.categoriesBox.putAt(index, category);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) category else state[i],
    ];
  }
  
  Future<void> deleteCategory(int index) async {
    await DatabaseService.categoriesBox.deleteAt(index);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
  
  Category? getCategoryByName(String name) {
    try {
      return state.firstWhere((category) => category.name == name);
    } catch (_) {
      return null;
    }
  }
}