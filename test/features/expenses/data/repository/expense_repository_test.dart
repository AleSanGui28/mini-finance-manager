import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/core/database/app_database.dart';
import 'package:mini_finance_manager/features/expenses/data/repository/expense_repository.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_frequency.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_type.dart';
import 'package:mini_finance_manager/features/expenses/domain/fixed_expense_category.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

void main() {
  group('ExpenseRepository', () {
    late AppDatabase database;
    late ExpenseRepository repository;

    setUp(() {
      database = AppDatabase.test(NativeDatabase.memory());
      repository = ExpenseRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('addExpense stores default colones currency in database', () async {
      await repository.addExpense(
        amount: 250,
        type: ExpenseType.sporadic,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 27),
      );

      final rows = await database.select(database.expensesTable).get();
      expect(rows.single.currency, 'crc');
    });

    test('addExpense stores and maps dollar currency', () async {
      await repository.addExpense(
        amount: 250,
        currency: MoneyCurrency.usd,
        type: ExpenseType.sporadic,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 27),
      );

      final rows = await database.select(database.expensesTable).get();
      expect(rows.single.currency, 'usd');

      final expenses = await repository.watchExpenses().first;
      expect(expenses.single.currency, MoneyCurrency.usd);
    });

    test('watchExpenses maps invalid stored currency to colones', () async {
      await database
          .into(database.expensesTable)
          .insert(
            ExpensesTableCompanion.insert(
              id: 'expense-1',
              amount: 250,
              currency: const drift.Value('invalid'),
              type: ExpenseType.sporadic.name,
              paymentAccountId: 'payment-account-1',
              date: DateTime(2026, 4, 27),
              createdAt: DateTime(2026, 4, 27),
            ),
          );

      final expenses = await repository.watchExpenses().first;
      expect(expenses.single.currency, MoneyCurrency.crc);
    });

    test('updateExpense updates an existing expense', () async {
      await repository.addExpense(
        amount: 250,
        type: ExpenseType.sporadic,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 27),
        description: 'Lunch',
      );

      final expense = (await repository.watchExpenses().first).single;

      await repository.updateExpense(
        Expense(
          id: expense.id,
          amount: 900,
          currency: MoneyCurrency.usd,
          type: ExpenseType.fixed,
          paymentAccountId: 'payment-account-2',
          date: DateTime(2026, 4, 28),
          createdAt: expense.createdAt,
          description: 'Updated rent',
          fixedCategory: FixedExpenseCategory.services,
          frequency: ExpenseFrequency.monthly,
        ),
      );

      final updatedExpense = (await repository.watchExpenses().first).single;
      expect(updatedExpense.id, expense.id);
      expect(updatedExpense.createdAt, expense.createdAt);
      expect(updatedExpense.amount, 900);
      expect(updatedExpense.currency, MoneyCurrency.usd);
      expect(updatedExpense.type, ExpenseType.fixed);
      expect(updatedExpense.paymentAccountId, 'payment-account-2');
      expect(updatedExpense.date, DateTime(2026, 4, 28));
      expect(updatedExpense.description, 'Updated rent');
      expect(updatedExpense.fixedCategory, FixedExpenseCategory.services);
      expect(updatedExpense.frequency, ExpenseFrequency.monthly);
      expect(updatedExpense.customFrequencyDescription, isNull);
    });

    test(
      'updateExpense clears fixed and custom fields when set to null',
      () async {
        await repository.addExpense(
          amount: 250,
          type: ExpenseType.fixed,
          paymentAccountId: 'payment-account-1',
          date: DateTime(2026, 4, 27),
          fixedCategory: FixedExpenseCategory.services,
          frequency: ExpenseFrequency.custom,
          customFrequencyDescription: 'Every 10 days',
        );

        final expense = (await repository.watchExpenses().first).single;

        await repository.updateExpense(
          Expense(
            id: expense.id,
            amount: expense.amount,
            currency: expense.currency,
            type: ExpenseType.sporadic,
            paymentAccountId: expense.paymentAccountId,
            date: expense.date,
            createdAt: expense.createdAt,
            description: expense.description,
          ),
        );

        final updatedExpense = (await repository.watchExpenses().first).single;
        expect(updatedExpense.type, ExpenseType.sporadic);
        expect(updatedExpense.fixedCategory, isNull);
        expect(updatedExpense.frequency, isNull);
        expect(updatedExpense.customFrequencyDescription, isNull);
      },
    );

    test('deleteExpense removes an existing expense', () async {
      await repository.addExpense(
        amount: 250,
        type: ExpenseType.sporadic,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 27),
      );

      final expense = (await repository.watchExpenses().first).single;

      await repository.deleteExpense(expense.id);

      final expenses = await repository.watchExpenses().first;
      expect(expenses, isEmpty);
    });
  });
}
