import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/personal/data/repository/saving_goal_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal_status.dart';
import 'package:mini_finance_manager/features/personal/presentation/add_saving_goal_page.dart';

class FakeSavingGoalRepository implements SavingGoalRepository {
  SavingGoal? updatedSavingGoal;
  String? addedTitle;
  double? addedTargetAmount;
  DateTime? addedTargetDate;

  @override
  Stream<List<SavingGoal>> watchSavingGoals() => Stream.value([]);

  @override
  Future<void> addSavingGoal({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
    SavingGoalStatus status = SavingGoalStatus.active,
  }) async {
    addedTitle = title;
    addedTargetAmount = targetAmount;
    addedTargetDate = targetDate;
  }

  @override
  Future<void> updateSavingGoal(SavingGoal savingGoal) async {
    updatedSavingGoal = savingGoal;
  }

  @override
  Future<void> deleteSavingGoal(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> freezeSavingGoal(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> resumeSavingGoal(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('AddSavingGoalPage', () {
    testWidgets('validates required title and amount', (tester) async {
      final repository = FakeSavingGoalRepository();

      await tester.pumpWidget(_buildPage(repository));

      await tester.tap(find.text('Guardar ahorro'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa un titulo o descripcion'), findsOneWidget);
      expect(find.text('Ingresa un monto valido'), findsOneWidget);
    });

    testWidgets('saves a new saving goal', (tester) async {
      final repository = FakeSavingGoalRepository();

      await tester.pumpWidget(_buildPage(repository));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titulo o descripcion'),
        'Fondo de emergencia',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Monto objetivo'),
        '1200',
      );
      await tester.tap(find.text('Guardar ahorro'));
      await tester.pumpAndSettle();

      expect(repository.addedTitle, 'Fondo de emergencia');
      expect(repository.addedTargetAmount, 1200);
      expect(repository.addedTargetDate, isNull);
    });

    testWidgets('edit mode pre-fills and preserves id and createdAt', (
      tester,
    ) async {
      final repository = FakeSavingGoalRepository();
      final createdAt = DateTime(2026, 4, 28);
      final savingGoal = SavingGoal(
        id: 'saving-goal-1',
        title: 'Laptop',
        targetAmount: 900,
        targetDate: DateTime(2026, 12, 31),
        status: SavingGoalStatus.frozen,
        createdAt: createdAt,
      );

      await tester.pumpWidget(_buildPage(repository, savingGoal: savingGoal));

      expect(find.text('Editar ahorro'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('900.00'), findsOneWidget);
      expect(find.text('31/12/2026'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Titulo o descripcion'),
        'Nueva laptop',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Monto objetivo'),
        '1100',
      );
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(repository.updatedSavingGoal?.id, 'saving-goal-1');
      expect(repository.updatedSavingGoal?.createdAt, createdAt);
      expect(repository.updatedSavingGoal?.status, SavingGoalStatus.frozen);
      expect(repository.updatedSavingGoal?.title, 'Nueva laptop');
      expect(repository.updatedSavingGoal?.targetAmount, 1100);
    });
  });
}

Widget _buildPage(
  FakeSavingGoalRepository repository, {
  SavingGoal? savingGoal,
}) {
  return MaterialApp(
    home: AddSavingGoalPage(repository: repository, savingGoal: savingGoal),
  );
}
