import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_dropdown.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;
  
  const AddExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  String _selectedPaymentMethod = 'Cash';
  List<String> _tags = [];
  String? _repeatFrequency;
  
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Mobile Payment'];
  final List<String> _repeatOptions = ['None', 'Daily', 'Weekly', 'Monthly'];
  
  @override
  void initState() {
    super.initState();
    
    // If editing an existing expense, populate the form
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes;
      _selectedDate = widget.expense!.date;
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedPaymentMethod = widget.expense!.paymentMethod;
      _tags = List.from(widget.expense!.tags);
      _repeatFrequency = widget.expense!.repeatFrequency;
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: categoriesAsyncValue.when(
        data: (categories) {
          // If no category is selected yet, select the first one
          if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Category dropdown
                CategoryDropdown(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  onChanged: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Date picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Payment method dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedPaymentMethod,
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Tags field
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tags',
                    prefixIcon: const Icon(Icons.tag),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addTag(context),
                    ),
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Repeat frequency dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Repeat',
                    prefixIcon: Icon(Icons.repeat),
                    border: OutlineInputBorder(),
                  ),
                  value: _repeatFrequency ?? 'None',
                  items: _repeatOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _repeatFrequency = value == 'None' ? null : value;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Notes field
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 24),
                
                // Save button
                ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.expense == null ? 'Add Expense' : 'Update Expense',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _addTag(BuildContext context) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter tag name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final tag = textController.text.trim();
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text;
      
      final expense = Expense(
        id: widget.expense?.id ?? const Uuid().v4(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        paymentMethod: _selectedPaymentMethod,
        tags: _tags,
        notes: notes,
        repeatFrequency: _repeatFrequency,
      );
      
      final apiService = ref.read(apiServiceProvider);
      
      try {
        if (widget.expense == null) {
          await apiService.createExpense(expense);
        } else {
          await apiService.updateExpense(expense.id, expense);
        }
        
        // Refresh expenses list
        ref.refresh(expensesProvider);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.expense == null
                    ? 'Expense added successfully'
                    : 'Expense updated successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}