import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';

void main() {
  group('PaymentAccountType income eligibility', () {
    test('allows bank account, debit card, and cash for incomes', () {
      expect(PaymentAccountType.bankAccount.canReceiveIncome, isTrue);
      expect(PaymentAccountType.debitCard.canReceiveIncome, isTrue);
      expect(PaymentAccountType.cash.canReceiveIncome, isTrue);
    });

    test('does not allow credit card or other for incomes', () {
      expect(PaymentAccountType.creditCard.canReceiveIncome, isFalse);
      expect(PaymentAccountType.other.canReceiveIncome, isFalse);
    });
  });
}
