import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/core/database/app_database.dart';
import 'package:mini_finance_manager/features/personal/data/repository/saving_goal_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal_status.dart';

void main() {
  group('SavingGoalRepository', () {
    late AppDatabase database;
    late SavingGoalRepository repository;

    setUp(() {
      database = AppDatabase.test(NativeDatabase.memory());
      repository = SavingGoalRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('addSavingGoal inserts an active goal into database', () async {
      final targetDate = DateTime(2026, 12, 31);

      await repository.addSavingGoal(
        title: 'Fondo de emergencia',
        targetAmount: 1500,
        targetDate: targetDate,
      );

      final savingGoals = await repository.watchSavingGoals().first;

      expect(savingGoals, hasLength(1));
      expect(savingGoals.single.id, isNotEmpty);
      expect(savingGoals.single.title, 'Fondo de emergencia');
      expect(savingGoals.single.targetAmount, 1500);
      expect(savingGoals.single.targetDate, targetDate);
      expect(savingGoals.single.status, SavingGoalStatus.active);
      expect(savingGoals.single.updatedAt, isNull);
    });

    test(
      'updateSavingGoal updates editable fields and preserves identity',
      () async {
        final createdAt = DateTime(2026, 4, 28);
        await _insertSavingGoal(database, createdAt: createdAt);

        await repository.updateSavingGoal(
          SavingGoal(
            id: 'saving-goal-1',
            title: 'Viaje',
            targetAmount: 2500,
            status: SavingGoalStatus.frozen,
            createdAt: createdAt,
          ),
        );

        final updatedGoal = (await repository.watchSavingGoals().first).single;

        expect(updatedGoal.id, 'saving-goal-1');
        expect(updatedGoal.createdAt, createdAt);
        expect(updatedGoal.title, 'Viaje');
        expect(updatedGoal.targetAmount, 2500);
        expect(updatedGoal.targetDate, isNull);
        expect(updatedGoal.status, SavingGoalStatus.frozen);
        expect(updatedGoal.updatedAt, isNotNull);
      },
    );

    test('deleteSavingGoal removes a goal', () async {
      await _insertSavingGoal(database);

      await repository.deleteSavingGoal('saving-goal-1');

      final savingGoals = await repository.watchSavingGoals().first;
      expect(savingGoals, isEmpty);
    });

    test('freezeSavingGoal only updates status and updatedAt', () async {
      final createdAt = DateTime(2026, 4, 28);
      final targetDate = DateTime(2026, 12, 31);
      await _insertSavingGoal(
        database,
        createdAt: createdAt,
        targetDate: targetDate,
      );

      await repository.freezeSavingGoal('saving-goal-1');

      final savingGoal = (await repository.watchSavingGoals().first).single;
      expect(savingGoal.title, 'Fondo de emergencia');
      expect(savingGoal.targetAmount, 1000);
      expect(savingGoal.targetDate, targetDate);
      expect(savingGoal.createdAt, createdAt);
      expect(savingGoal.status, SavingGoalStatus.frozen);
      expect(savingGoal.updatedAt, isNotNull);
    });

    test('resumeSavingGoal sets a frozen goal back to active', () async {
      await _insertSavingGoal(database, status: SavingGoalStatus.frozen);

      await repository.resumeSavingGoal('saving-goal-1');

      final savingGoal = (await repository.watchSavingGoals().first).single;
      expect(savingGoal.status, SavingGoalStatus.active);
      expect(savingGoal.updatedAt, isNotNull);
    });

    test('watchSavingGoals maps invalid stored status to active', () async {
      await _insertSavingGoal(database, statusValue: 'unknown');

      final savingGoal = (await repository.watchSavingGoals().first).single;
      expect(savingGoal.status, SavingGoalStatus.active);
    });
  });
}

Future<void> _insertSavingGoal(
  AppDatabase database, {
  String id = 'saving-goal-1',
  String title = 'Fondo de emergencia',
  double targetAmount = 1000,
  DateTime? targetDate,
  SavingGoalStatus status = SavingGoalStatus.active,
  String? statusValue,
  DateTime? createdAt,
}) {
  return database
      .into(database.savingGoalsTable)
      .insert(
        SavingGoalsTableCompanion.insert(
          id: id,
          title: title,
          targetAmount: targetAmount,
          targetDate: drift.Value(targetDate),
          status: statusValue ?? status.name,
          createdAt: createdAt ?? DateTime(2026, 4, 28),
        ),
      );
}
