import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final int iconCodePoint;

  @HiveField(4)
  final String? iconFontFamily;

  @HiveField(5)
  final bool isDefault;

  Category({
    String? id,
    required this.name,
    required this.colorValue,
    required IconData icon,
    this.isDefault = false,
  }) : 
    id = id ?? const Uuid().v4(),
    iconCodePoint = icon.codePoint,
    iconFontFamily = icon.fontFamily;

  Color get color => Color(colorValue);

  IconData get icon => IconData(
    iconCodePoint,
    fontFamily: iconFontFamily,
  );

  Category copyWith({
    String? name,
    int? colorValue,
    IconData? icon,
    bool? isDefault,
  }) {
    return Category(
      id: this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static List<Category> defaultCategories() {
    return [
      Category(
        id: 'food',
        name: 'Food & Dining',
        colorValue: Colors.red.value,
        icon: Icons.restaurant,
        isDefault: true,
      ),
      Category(
        id: 'transportation',
        name: 'Transportation',
        colorValue: Colors.blue.value,
        icon: Icons.directions_car,
        isDefault: true,
      ),
      Category(
        id: 'entertainment',
        name: 'Entertainment',
        colorValue: Colors.purple.value,
        icon: Icons.movie,
        isDefault: true,
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        colorValue: Colors.pink.value,
        icon: Icons.shopping_bag,
        isDefault: true,
      ),
      Category(
        id: 'utilities',
        name: 'Utilities',
        colorValue: Colors.orange.value,
        icon: Icons.power,
        isDefault: true,
      ),
      Category(
        id: 'health',
        name: 'Health',
        colorValue: Colors.green.value,
        icon: Icons.medical_services,
        isDefault: true,
      ),
      Category(
        id: 'education',
        name: 'Education',
        colorValue: Colors.amber.value,
        icon: Icons.school,
        isDefault: true,
      ),
      Category(
        id: 'other',
        name: 'Other',
        colorValue: Colors.grey.value,
        icon: Icons.more_horiz,
        isDefault: true,
      ),
    ];
  }
}
