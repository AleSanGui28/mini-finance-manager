import '../../shared/domain/money_currency.dart';
import 'expense_frequency.dart';
import 'expense_type.dart';
import 'fixed_expense_category.dart';

class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.type,
    required this.paymentAccountId,
    required this.date,
    required this.createdAt,
    this.currency = MoneyCurrency.crc,
    this.description,
    this.fixedCategory,
    this.frequency,
    this.customFrequencyDescription,
  });

  final String id;
  final double amount;
  final ExpenseType type;
  final String paymentAccountId;
  final DateTime date;
  final DateTime createdAt;
  final MoneyCurrency currency;
  final String? description;
  final FixedExpenseCategory? fixedCategory;
  final ExpenseFrequency? frequency;
  final String? customFrequencyDescription;
}
