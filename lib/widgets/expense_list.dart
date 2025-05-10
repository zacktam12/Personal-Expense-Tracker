import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class ExpenseList extends ConsumerWidget {
  final List<Expense> expenses;
  final Function(Expense) onTap;
  final Function(String) onDelete;

  const ExpenseList({
    Key? key,
    required this.expenses,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    if (expenses.isEmpty) {
      return const Center(
        child: Text('No expenses found'),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final category = categories.firstWhere(
          (c) => c.name == expense.category,
          orElse: () => Category(
            name: 'Other',
            icon: 'more_horiz',
            color: '808080',
          ),
        );

        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) => onDelete(expense.id),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.colorValue,
              child: Icon(
                IconData(
                  int.parse('0xe${category.icon}', radix: 16),
                  fontFamily: 'MaterialIcons',
                ),
                color: Colors.white,
              ),
            ),
            title: Text(expense.category),
            subtitle: Text(
              DateFormat.yMMMd().format(expense.date),
            ),
            trailing: Text(
              currencyFormat.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () => onTap(expense),
          ),
        );
      },
    );
  }
}