import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/income.dart';
import '../../domain/income_category.dart';

class IncomeRepository {
  final AppDatabase _database;

  IncomeRepository(this._database);

  Stream<List<Income>> watchIncomes() {
    return _database.select(_database.incomesTable).watch().map((rows) {
      return rows.map(_mapRowToIncome).toList();
    });
  }

  Future<void> addIncome({
    required double amount,
    required IncomeCategory category,
    required DateTime date,
    required String description,
  }) {
    final incomeRow = IncomesTableCompanion(
      id: drift.Value(const Uuid().v4()),
      amount: drift.Value(amount),
      category: drift.Value(category.name),
      date: drift.Value(date),
      description: drift.Value(description),
      createdAt: drift.Value(DateTime.now()),
    );

    return _database.into(_database.incomesTable).insert(incomeRow);
  }

  Income _mapRowToIncome(IncomesTableData row) {
    return Income(
      id: row.id,
      amount: row.amount,
      category: IncomeCategory.values.firstWhere((e) => e.name == row.category),
      date: row.date,
      createdAt: row.createdAt,
      description: row.description,
    );
  }
}
