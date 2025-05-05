import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryDropdown extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String) onChanged;
  
  const CategoryDropdown({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategoryId,
          isDense: true,
          isExpanded: true,
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}