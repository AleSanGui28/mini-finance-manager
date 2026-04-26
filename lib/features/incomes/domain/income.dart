import 'income_category.dart';

class Income {
  const Income({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
    required this.description,
  });

  final String id;
  final double amount;
  final IncomeCategory category;
  final DateTime date;
  final DateTime createdAt;
  final String description;
}
