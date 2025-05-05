class Expense {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String paymentMethod;
  final List<String> tags;
  final String notes;
  final String? repeatFrequency; // daily, weekly, monthly, null for one-time

  Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.paymentMethod,
    this.tags = const [],
    this.notes = '',
    this.repeatFrequency,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      categoryId: json['categoryId'],
      date: DateTime.parse(json['date']),
      paymentMethod: json['paymentMethod'],
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'] ?? '',
      repeatFrequency: json['repeatFrequency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'paymentMethod': json['paymentMethod'],
      'tags': tags,
      'notes': notes,
      'repeatFrequency': repeatFrequency,
    };
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? paymentMethod,
    List<String>? tags,
    String? notes,
    String? repeatFrequency,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
    );
  }
}