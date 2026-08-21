import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/expense.dart' as domain;
import '../../domain/expense_frequency.dart';
import '../../domain/expense_type.dart';
import '../../domain/fixed_expense_category.dart';
import '../../../shared/domain/money_currency.dart';

class ExpenseRepository {
  ExpenseRepository(this._database);

  final AppDatabase _database;

  final _uuid = const Uuid();

  Stream<List<domain.Expense>> watchExpenses() {
    final query = _database.select(_database.expensesTable)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);

    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

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
  }) async {
    await _database
        .into(_database.expensesTable)
        .insert(
          ExpensesTableCompanion.insert(
            id: _uuid.v4(),
            amount: amount,
            currency: Value(currency.name),
            type: type.name,
            paymentAccountId: paymentAccountId,
            date: date,
            description: Value(description),
            fixedCategory: Value(fixedCategory?.name),
            frequency: Value(frequency?.name),
            customFrequencyDescription: Value(customFrequencyDescription),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> updateExpense(domain.Expense expense) async {
    final expenseRow = ExpensesTableCompanion(
      id: Value(expense.id),
      amount: Value(expense.amount),
      currency: Value(expense.currency.name),
      type: Value(expense.type.name),
      paymentAccountId: Value(expense.paymentAccountId),
      date: Value(expense.date),
      description: Value<String?>(expense.description),
      fixedCategory: Value<String?>(expense.fixedCategory?.name),
      frequency: Value<String?>(expense.frequency?.name),
      customFrequencyDescription: Value<String?>(
        expense.customFrequencyDescription,
      ),
      createdAt: Value(expense.createdAt),
    );

    await _database.update(_database.expensesTable).replace(expenseRow);
  }

  Future<void> deleteExpense(String id) {
    return (_database.delete(
      _database.expensesTable,
    )..where((table) => table.id.equals(id))).go();
  }

  domain.Expense _mapRow(ExpensesTableData row) {
    ExpenseType expenseType = ExpenseType.fixed;
    try {
      expenseType = ExpenseType.values.firstWhere((e) => e.name == row.type);
    } catch (e) {
      expenseType = ExpenseType.fixed;
    }

    FixedExpenseCategory? fixedCategory;
    if (row.fixedCategory != null) {
      try {
        fixedCategory = FixedExpenseCategory.values.firstWhere(
          (e) => e.name == row.fixedCategory,
        );
      } catch (e) {
        fixedCategory = null;
      }
    }

    ExpenseFrequency? frequency;
    if (row.frequency != null) {
      try {
        frequency = ExpenseFrequency.values.firstWhere(
          (e) => e.name == row.frequency,
        );
      } catch (e) {
        frequency = null;
      }
    }

    return domain.Expense(
      id: row.id,
      amount: row.amount,
      currency: _mapCurrency(row.currency),
      type: expenseType,
      paymentAccountId: row.paymentAccountId,
      date: row.date,
      createdAt: row.createdAt,
      description: row.description,
      fixedCategory: fixedCategory,
      frequency: frequency,
      customFrequencyDescription: row.customFrequencyDescription,
    );
  }

  MoneyCurrency _mapCurrency(String value) {
    return MoneyCurrency.values.firstWhere(
      (currency) => currency.name == value,
      orElse: () => MoneyCurrency.crc,
    );
  }
}
