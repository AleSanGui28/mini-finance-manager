import 'payment_account_type.dart';

class PaymentAccount {
  const PaymentAccount({
    required this.id,
    required this.bankName,
    required this.alias,
    required this.type,
    required this.createdAt,
    this.closingDayOfMonth,
    this.cardLastDigits,
    this.iban,
  });

  final String id;
  final String bankName;
  final String alias;
  final PaymentAccountType type;
  final DateTime createdAt;
  final int? closingDayOfMonth;
  final String? cardLastDigits;
  final String? iban;
}
