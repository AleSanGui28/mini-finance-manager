import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/balance/presentation/balance_page.dart';
import 'package:mini_finance_manager/features/expenses/data/repository/expense_repository.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_frequency.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_type.dart';
import 'package:mini_finance_manager/features/expenses/domain/fixed_expense_category.dart';
import 'package:mini_finance_manager/features/incomes/data/repository/income_repository.dart';
import 'package:mini_finance_manager/features/incomes/domain/income.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

class FakeIncomeRepository implements IncomeRepository {
  FakeIncomeRepository(this.incomes);

  final List<Income> incomes;

  @override
  Stream<List<Income>> watchIncomes() => Stream.value(incomes);

  @override
  Future<void> addIncome({
    required double amount,
    MoneyCurrency currency = MoneyCurrency.crc,
    required String paymentAccountId,
    required IncomeCategory category,
    required DateTime date,
    required String description,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateIncome(Income income) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteIncome(String id) {
    throw UnimplementedError();
  }
}

class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository(this.expenses);

  final List<Expense> expenses;

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);

  @override
  Future<void> addExpense({
    required double amount,
    MoneyCurrency currency = MoneyCurrency.crc,
    required ExpenseType type,
    required String paymentAccountId,
    required DateTime date,
    String? description,
    FixedExpenseCategory? fixedCategory,
    ExpenseFrequency? frequency,
    String? customFrequencyDescription,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateExpense(Expense expense) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExpense(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('BalancePage', () {
    testWidgets('renders total incomes expenses balance and status', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildPage(
          incomes: [_income(amount: 1000)],
          expenses: [_expense(amount: 400)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Balance'), findsWidgets);
      expect(find.text('Total ingresos'), findsOneWidget);
      expect(find.text('Total gastos'), findsOneWidget);
      expect(find.text('${MoneyCurrency.crc.symbol}1000.00'), findsOneWidget);
      expect(find.text('${MoneyCurrency.crc.symbol}400.00'), findsOneWidget);
      expect(find.text('${MoneyCurrency.crc.symbol}600.00'), findsOneWidget);
      expect(find.text('Beneficio'), findsOneWidget);
    });

    testWidgets('renders deficit status for negative balance', (tester) async {
      await tester.pumpWidget(
        _buildPage(
          incomes: [_income(amount: 200)],
          expenses: [_expense(amount: 350)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('-${MoneyCurrency.crc.symbol}150.00'), findsOneWidget);
      expect(find.text('Déficit'), findsOneWidget);
    });

    testWidgets('renders neutral state for empty data', (tester) async {
      await tester.pumpWidget(_buildPage(incomes: [], expenses: []));
      await tester.pumpAndSettle();

      expect(find.text('${MoneyCurrency.crc.symbol}0.00'), findsNWidgets(3));
      expect(find.text('Balance neutro'), findsOneWidget);
    });
  });
}

Widget _buildPage({
  required List<Income> incomes,
  required List<Expense> expenses,
}) {
  return MaterialApp(
    home: BalancePage(
      incomeRepository: FakeIncomeRepository(incomes),
      expenseRepository: FakeExpenseRepository(expenses),
    ),
  );
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
