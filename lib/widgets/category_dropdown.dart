import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoryDropdown extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;
  final bool showAddButton;

  const CategoryDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
    this.showAddButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
            ),
            items: categories.map<DropdownMenuItem<String>>((Category category) {
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
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
        ),
        if (showAddButton) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              _showAddCategoryDialog(context);
            },
            tooltip: 'Add new category',
          ),
        ],
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddCategoryDialog();
      },
    ).then((newCategoryId) {
      if (newCategoryId != null) {
        onChanged(newCategoryId);
      }
    });
  }
}

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({Key? key}) : super(key: key);

  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  final List<IconData> _icons = [
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.local_grocery_store,
    Icons.directions_car,
    Icons.directions_bus,
    Icons.flight,
    Icons.home,
    Icons.house,
    Icons.weekend,
    Icons.hotel,
    Icons.school,
    Icons.book,
    Icons.medical_services,
    Icons.local_hospital,
    Icons.fitness_center,
    Icons.sports,
    Icons.movie,
    Icons.music_note,
    Icons.games,
    Icons.sports_esports,
    Icons.card_giftcard,
    Icons.celebration,
    Icons.cake,
    Icons.child_care,
    Icons.pets,
    Icons.emoji_nature,
    Icons.beach_access,
    Icons.ac_unit,
    Icons.whatshot,
    Icons.power,
    Icons.wifi,
    Icons.phone,
    Icons.computer,
    Icons.tv,
    Icons.camera_alt,
    Icons.attach_money,
    Icons.account_balance,
    Icons.credit_card,
    Icons.savings,
    Icons.work,
    Icons.business_center,
    Icons.category,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Color'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: _selectedColor == color
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Select Icon'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? _selectedColor.withOpacity(0.2)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedIcon == icon
                                ? _selectedColor
                                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: _selectedIcon == icon
                              ? _selectedColor
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
              final newCategory = Category(
                name: _nameController.text.trim(),
                colorValue: _selectedColor.value,
                icon: _selectedIcon,
              );
              
              categoryProvider.addCategory(newCategory);
              Navigator.of(context).pop(newCategory.id);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
