import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String icon;

  @HiveField(2)
  final String color;

  Category({
    required this.name,
    required this.icon,
    required this.color,
  });

  // Helper method to get color as a Color object
  Color get colorValue => Color(int.parse(color, radix: 16) | 0xFF000000);

  // Create a copy of this category with optional new values
  Category copyWith({
    String? name,
    String? icon,
    String? color,
  }) {
    return Category(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  // Default categories
  static List<Category> defaultCategories() {
    return [
      Category(
        name: 'Food',
        icon: 'restaurant',
        color: 'FF6D28',
      ),
      Category(
        name: 'Transport',
        icon: 'directions_car',
        color: '367BF5',
      ),
      Category(
        name: 'Shopping',
        icon: 'shopping_bag',
        color: 'D800A6',
      ),
      Category(
        name: 'Bills',
        icon: 'receipt',
        color: '16BF78',
      ),
      Category(
        name: 'Entertainment',
        icon: 'movie',
        color: 'F2BD27',
      ),
      Category(
        name: 'Other',
        icon: 'more_horiz',
        color: '808080',
      ),
    ];
  }
}