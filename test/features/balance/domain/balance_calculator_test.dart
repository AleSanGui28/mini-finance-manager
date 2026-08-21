import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/balance/domain/balance_calculator.dart';
import 'package:mini_finance_manager/features/balance/domain/balance_status.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_type.dart';
import 'package:mini_finance_manager/features/incomes/domain/income.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

void main() {
  group('BalanceCalculator', () {
    test('returns surplus when incomes are greater than expenses', () {
      final summaries = BalanceCalculator.build(
        incomes: [_income(amount: 1000)],
        expenses: [_expense(amount: 400)],
      );

      expect(summaries, hasLength(1));
      expect(summaries.single.totalIncomes, 1000);
      expect(summaries.single.totalExpenses, 400);
      expect(summaries.single.balance, 600);
      expect(summaries.single.status, BalanceStatus.surplus);
    });

    test('returns deficit when expenses are greater than incomes', () {
      final summaries = BalanceCalculator.build(
        incomes: [_income(amount: 200)],
        expenses: [_expense(amount: 350)],
      );

      expect(summaries.single.totalIncomes, 200);
      expect(summaries.single.totalExpenses, 350);
      expect(summaries.single.balance, -150);
      expect(summaries.single.status, BalanceStatus.deficit);
    });

    test('returns neutral when incomes and expenses are equal', () {
      final summaries = BalanceCalculator.build(
        incomes: [_income(amount: 500)],
        expenses: [_expense(amount: 500)],
      );

      expect(summaries.single.balance, 0);
      expect(summaries.single.status, BalanceStatus.neutral);
    });

    test('returns neutral crc summary for empty incomes and expenses', () {
      final summaries = BalanceCalculator.build(incomes: [], expenses: []);

      expect(summaries, hasLength(1));
      expect(summaries.single.currency, MoneyCurrency.crc);
      expect(summaries.single.totalIncomes, 0);
      expect(summaries.single.totalExpenses, 0);
      expect(summaries.single.balance, 0);
      expect(summaries.single.status, BalanceStatus.neutral);
    });

    test('keeps balances separated by currency', () {
      final summaries = BalanceCalculator.build(
        incomes: [
          _income(id: 'income-crc', amount: 1000),
          _income(id: 'income-usd', amount: 50, currency: MoneyCurrency.usd),
        ],
        expenses: [
          _expense(id: 'expense-crc', amount: 300),
          _expense(id: 'expense-usd', amount: 75, currency: MoneyCurrency.usd),
        ],
      );

      final crcSummary = summaries.singleWhere(
        (summary) => summary.currency == MoneyCurrency.crc,
      );
      final usdSummary = summaries.singleWhere(
        (summary) => summary.currency == MoneyCurrency.usd,
      );

      expect(crcSummary.balance, 700);
      expect(crcSummary.status, BalanceStatus.surplus);
      expect(usdSummary.balance, -25);
      expect(usdSummary.status, BalanceStatus.deficit);
    });
  });
}

Income _income({
  String id = 'income-1',
  required double amount,
  MoneyCurrency currency = MoneyCurrency.crc,
}) {
  return Income(
    id: id,
    amount: amount,
    currency: currency,
    paymentAccountId: 'payment-account-1',
    category: IncomeCategory.salary,
    date: DateTime(2026, 5, 7),
    createdAt: DateTime(2026, 5, 7),
    description: '',
  );
}

Expense _expense({
  String id = 'expense-1',
  required double amount,
  MoneyCurrency currency = MoneyCurrency.crc,
}) {
  return Expense(
    id: id,
    amount: amount,
    currency: currency,
    type: ExpenseType.sporadic,
    paymentAccountId: 'payment-account-1',
    date: DateTime(2026, 5, 7),
    createdAt: DateTime(2026, 5, 7),
  );
}
