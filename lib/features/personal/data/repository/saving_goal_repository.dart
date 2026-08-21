import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/saving_goal.dart';
import '../../domain/saving_goal_status.dart';

class SavingGoalRepository {
  SavingGoalRepository(this._database);

  final AppDatabase _database;
  final _uuid = const Uuid();

  Stream<List<SavingGoal>> watchSavingGoals() {
    final query = _database.select(_database.savingGoalsTable)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    return query.watch().map((rows) => rows.map(_mapRowToSavingGoal).toList());
  }

  Future<void> addSavingGoal({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
    SavingGoalStatus status = SavingGoalStatus.active,
  }) {
    return _database
        .into(_database.savingGoalsTable)
        .insert(
          SavingGoalsTableCompanion.insert(
            id: _uuid.v4(),
            title: title,
            targetAmount: targetAmount,
            targetDate: Value(targetDate),
            status: status.name,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> updateSavingGoal(SavingGoal savingGoal) {
    final savingGoalRow = SavingGoalsTableCompanion(
      id: Value(savingGoal.id),
      title: Value(savingGoal.title),
      targetAmount: Value(savingGoal.targetAmount),
      targetDate: Value<DateTime?>(savingGoal.targetDate),
      status: Value(savingGoal.status.name),
      createdAt: Value(savingGoal.createdAt),
      updatedAt: Value(DateTime.now()),
    );

    return _database.update(_database.savingGoalsTable).replace(savingGoalRow);
  }

  Future<void> deleteSavingGoal(String id) {
    return (_database.delete(
      _database.savingGoalsTable,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> freezeSavingGoal(String id) {
    return _updateStatus(id, SavingGoalStatus.frozen);
  }

  Future<void> resumeSavingGoal(String id) {
    return _updateStatus(id, SavingGoalStatus.active);
  }

  Future<void> _updateStatus(String id, SavingGoalStatus status) {
    return (_database.update(
      _database.savingGoalsTable,
    )..where((table) => table.id.equals(id))).write(
      SavingGoalsTableCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  SavingGoal _mapRowToSavingGoal(SavingGoalsTableData row) {
    return SavingGoal(
      id: row.id,
      title: row.title,
      targetAmount: row.targetAmount,
      targetDate: row.targetDate,
      status: _mapStatus(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  SavingGoalStatus _mapStatus(String value) {
    return SavingGoalStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SavingGoalStatus.active,
    );
  }
}
