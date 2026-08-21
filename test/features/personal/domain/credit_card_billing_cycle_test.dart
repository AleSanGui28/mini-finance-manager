import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/personal/domain/credit_card_billing_cycle.dart';

void main() {
  group('CreditCardBillingCycle', () {
    test('calculates payment window without month rollover', () {
      const cycle = CreditCardBillingCycle(closingDayOfMonth: 3);

      expect(cycle.paymentStartDay, 3);
      expect(cycle.paymentEndDay, 18);
      expect(cycle.rollsToNextMonth, isFalse);
    });

    test('calculates payment window with month rollover', () {
      const cycle = CreditCardBillingCycle(closingDayOfMonth: 25);

      expect(cycle.paymentStartDay, 25);
      expect(cycle.paymentEndDay, 10);
      expect(cycle.rollsToNextMonth, isTrue);
    });

    test('validates closing day boundaries', () {
      expect(CreditCardBillingCycle.isValidClosingDayOfMonth(null), isFalse);
      expect(CreditCardBillingCycle.isValidClosingDayOfMonth(0), isFalse);
      expect(CreditCardBillingCycle.isValidClosingDayOfMonth(1), isTrue);
      expect(CreditCardBillingCycle.isValidClosingDayOfMonth(31), isTrue);
      expect(CreditCardBillingCycle.isValidClosingDayOfMonth(32), isFalse);
    });
  });
}
