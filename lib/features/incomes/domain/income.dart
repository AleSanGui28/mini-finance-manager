import '../../shared/domain/money_currency.dart';
import 'income_category.dart';

class Income {
  const Income({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
    required this.description,
    this.currency = MoneyCurrency.crc,
    this.paymentAccountId,
  });

  final String id;
  final double amount;
  final MoneyCurrency currency;
  final String? paymentAccountId;
  final IncomeCategory category;
  final DateTime date;
  final DateTime createdAt;
  final String description;
}
