import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoryDropdown extends ConsumerWidget {
  final String? value;
  final Function(String?) onChanged;

  const CategoryDropdown({
    Key? key,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: categories.map((Category category) {
        return DropdownMenuItem<String>(
          value: category.name,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: category.colorValue,
                radius: 12,
                child: Icon(
                  IconData(
                    int.parse('0xe${category.icon}', radix: 16),
                    fontFamily: 'MaterialIcons',
                  ),
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }
}