import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/personal/data/repository/saving_goal_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal_status.dart';
import 'package:mini_finance_manager/features/personal/presentation/add_saving_goal_page.dart';
import 'package:mini_finance_manager/features/personal/presentation/saving_goal_detail_page.dart';
import 'package:mini_finance_manager/features/personal/presentation/savings_page.dart';

class FakeSavingGoalRepository implements SavingGoalRepository {
  FakeSavingGoalRepository(this.savingGoals);

  final List<SavingGoal> savingGoals;
  final deletedIds = <String>[];
  final frozenIds = <String>[];
  final resumedIds = <String>[];

  @override
  Stream<List<SavingGoal>> watchSavingGoals() => Stream.value(savingGoals);

  @override
  Future<void> addSavingGoal({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
    SavingGoalStatus status = SavingGoalStatus.active,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateSavingGoal(SavingGoal savingGoal) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSavingGoal(String id) async {
    deletedIds.add(id);
  }

  @override
  Future<void> freezeSavingGoal(String id) async {
    frozenIds.add(id);
  }

  @override
  Future<void> resumeSavingGoal(String id) async {
    resumedIds.add(id);
  }
}

void main() {
  group('SavingsPage', () {
    testWidgets('shows empty state', (tester) async {
      final repository = FakeSavingGoalRepository([]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      expect(find.text('Ahorros'), findsOneWidget);
      expect(find.text('Meta total'), findsOneWidget);
      expect(find.text('0.00'), findsOneWidget);
      expect(find.text('No hay metas de ahorro'), findsOneWidget);
    });

    testWidgets('renders saving goals with status and deadline', (
      tester,
    ) async {
      final repository = FakeSavingGoalRepository([
        _savingGoal(),
        _savingGoal(
          id: 'saving-goal-2',
          title: 'Viaje',
          targetAmount: 2000,
          status: SavingGoalStatus.frozen,
          withoutTargetDate: true,
        ),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('Objetivo: 1000.00'), findsOneWidget);
      expect(find.text('Fecha limite: 31/12/2026'), findsOneWidget);
      expect(find.text('Viaje'), findsOneWidget);
      expect(find.text('Sin limite de tiempo'), findsOneWidget);
      expect(find.text('Activo'), findsOneWidget);
      expect(find.text('Congelado'), findsOneWidget);
    });

    testWidgets('opens detail when tapping a saving goal', (tester) async {
      final repository = FakeSavingGoalRepository([_savingGoal()]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Laptop'));
      await tester.pumpAndSettle();

      expect(find.byType(SavingGoalDetailPage), findsOneWidget);
      expect(find.text('Detalle del ahorro'), findsOneWidget);
      expect(find.text('Congelar'), findsOneWidget);
    });

    testWidgets('freezes active saving goal from detail page', (tester) async {
      final repository = FakeSavingGoalRepository([_savingGoal()]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Laptop'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Congelar'));
      await tester.pumpAndSettle();

      expect(repository.frozenIds, ['saving-goal-1']);
      expect(find.text('Meta congelada'), findsOneWidget);
      expect(find.text('Reanudar'), findsOneWidget);
    });

    testWidgets('opens saving goal editor when swiping right', (tester) async {
      final repository = FakeSavingGoalRepository([_savingGoal()]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _swipeRight(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AddSavingGoalPage), findsOneWidget);
      expect(find.text('Editar ahorro'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
    });

    testWidgets('does not delete when swipe confirmation is cancelled', (
      tester,
    ) async {
      final repository = FakeSavingGoalRepository([_savingGoal()]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _swipeLeft(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repository.deletedIds, isEmpty);
      expect(find.text('Laptop'), findsOneWidget);
    });

    testWidgets('deletes when swipe confirmation is accepted', (tester) async {
      final repository = FakeSavingGoalRepository([_savingGoal()]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _swipeLeft(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(repository.deletedIds, ['saving-goal-1']);
      expect(find.text('Meta de ahorro eliminada'), findsOneWidget);
    });
  });
}

Widget _buildPage(FakeSavingGoalRepository repository) {
  return MaterialApp(home: SavingsPage(repository: repository));
}

SavingGoal _savingGoal({
  String id = 'saving-goal-1',
  String title = 'Laptop',
  double targetAmount = 1000,
  SavingGoalStatus status = SavingGoalStatus.active,
  DateTime? targetDate,
  bool withoutTargetDate = false,
}) {
  return SavingGoal(
    id: id,
    title: title,
    targetAmount: targetAmount,
    targetDate: withoutTargetDate ? null : targetDate ?? DateTime(2026, 12, 31),
    status: status,
    createdAt: DateTime(2026, 4, 28),
  );
}

Future<void> _swipeRight(WidgetTester tester) async {
  await _dragSavingGoal(tester, const Offset(120, 0));
}

Future<void> _swipeLeft(WidgetTester tester) async {
  await _dragSavingGoal(tester, const Offset(-120, 0));
}

Future<void> _dragSavingGoal(WidgetTester tester, Offset offset) async {
  final row = find.byWidgetPredicate(
    (widget) =>
        widget is GestureDetector && widget.onHorizontalDragUpdate != null,
  );
  await tester.drag(row.first, offset);
  await tester.pumpAndSettle();
}
