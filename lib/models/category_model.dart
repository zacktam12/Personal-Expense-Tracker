import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.isDefault = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'iconCodePoint': icon.codePoint,
      'isDefault': isDefault,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// Default categories
List<Category> defaultCategories = [
  Category(
    id: '1',
    name: 'Food',
    color: Colors.red,
    icon: Icons.restaurant,
    isDefault: true,
  ),
  Category(
    id: '2',
    name: 'Transport',
    color: Colors.blue,
    icon: Icons.directions_car,
    isDefault: true,
  ),
  Category(
    id: '3',
    name: 'Entertainment',
    color: Colors.purple,
    icon: Icons.movie,
    isDefault: true,
  ),
  Category(
    id: '4',
    name: 'Utilities',
    color: Colors.orange,
    icon: Icons.power,
    isDefault: true,
  ),
  Category(
    id: '5',
    name: 'Shopping',
    color: Colors.green,
    icon: Icons.shopping_bag,
    isDefault: true,
  ),
  Category(
    id: '6',
    name: 'Health',
    color: Colors.teal,
    icon: Icons.medical_services,
    isDefault: true,
  ),
];