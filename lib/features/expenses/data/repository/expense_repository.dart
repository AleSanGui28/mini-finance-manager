import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/expense.dart' as domain;
import '../../domain/expense_frequency.dart';
import '../../domain/expense_type.dart';
import '../../domain/fixed_expense_category.dart';

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

  domain.Expense _mapRow(ExpensesTableData row) {
    String expenseType = ExpenseType.fixed.name;
    try {
      // Validate that the type exists in the enum
      ExpenseType.values.firstWhere((e) => e.name == row.type);
      expenseType = row.type;
    } catch (e) {
      expenseType = ExpenseType.fixed.name;
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
}
