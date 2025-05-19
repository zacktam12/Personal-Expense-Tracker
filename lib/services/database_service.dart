import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';

class DatabaseService {
  static const String expenseBoxName = 'expenses';
  static const String categoryBoxName = 'categories';
  static const String settingsBoxName = 'settings';

  static Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }

    // Open boxes
    await Hive.openBox<Expense>(expenseBoxName);
    await Hive.openBox<Category>(categoryBoxName);
    await Hive.openBox(settingsBoxName);

    // Initialize default categories if none exist
    final categoryBox = Hive.box<Category>(categoryBoxName);
    if (categoryBox.isEmpty) {
      final defaultCategories = Category.defaultCategories();
      for (var category in defaultCategories) {
        await categoryBox.put(category.id, category);
      }
    }
  }

  static Box<Expense> getExpenseBox() {
    return Hive.box<Expense>(expenseBoxName);
  }

  static Box<Category> getCategoryBox() {
    return Hive.box<Category>(categoryBoxName);
  }

  static Box getSettingsBox() {
    return Hive.box(settingsBoxName);
  }

  static Future<void> clearAllData() async {
    await getExpenseBox().clear();
    
    // Clear categories but keep default ones
    final categoryBox = getCategoryBox();
    final defaultCategories = Category.defaultCategories();
    await categoryBox.clear();
    
    for (var category in defaultCategories) {
      await categoryBox.put(category.id, category);
    }
  }
}
