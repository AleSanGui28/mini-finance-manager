import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_type.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

void main() {
  group('Expense', () {
    test('creates expense with default colones currency', () {
      final date = DateTime(2026, 4, 27);
      final createdAt = DateTime(2026, 4, 27, 10, 30);

      final expense = Expense(
        id: 'expense-1',
        amount: 250,
        type: ExpenseType.sporadic,
        paymentAccountId: 'account-1',
        date: date,
        createdAt: createdAt,
        description: 'Lunch',
      );

      expect(expense.id, 'expense-1');
      expect(expense.amount, 250);
      expect(expense.currency, MoneyCurrency.crc);
      expect(expense.type, ExpenseType.sporadic);
      expect(expense.paymentAccountId, 'account-1');
      expect(expense.date, date);
      expect(expense.createdAt, createdAt);
      expect(expense.description, 'Lunch');
    });

    test('creates expense with dollar currency', () {
      final expense = Expense(
        id: 'expense-1',
        amount: 40,
        currency: MoneyCurrency.usd,
        type: ExpenseType.sporadic,
        paymentAccountId: 'account-1',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(expense.currency, MoneyCurrency.usd);
    });
  });
}
