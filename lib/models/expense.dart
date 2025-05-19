import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final String? notes;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Expense copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? notes,
  }) {
    return Expense(
      id: this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
    );
  }
}
