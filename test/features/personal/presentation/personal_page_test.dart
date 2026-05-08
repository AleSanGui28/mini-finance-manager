import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/data/repository/saving_goal_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal_status.dart';
import 'package:mini_finance_manager/features/personal/presentation/payment_accounts_page.dart';
import 'package:mini_finance_manager/features/personal/presentation/personal_page.dart';
import 'package:mini_finance_manager/features/personal/presentation/savings_page.dart';

class FakePaymentAccountRepository implements PaymentAccountRepository {
  FakePaymentAccountRepository(this.accounts, {this.blockDelete = false});

  final List<PaymentAccount> accounts;
  final bool blockDelete;
  final deletedIds = <String>[];
  PaymentAccount? updatedAccount;

  @override
  Stream<List<PaymentAccount>> watchPaymentAccounts() => Stream.value(accounts);

  @override
  Future<void> addPaymentAccount({
    required String bankName,
    required String alias,
    required PaymentAccountType type,
    String? cardLastDigits,
    String? iban,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePaymentAccount(PaymentAccount paymentAccount) async {
    updatedAccount = paymentAccount;
  }

  @override
  Future<PaymentAccountLinkedRecordCounts> getLinkedRecordCounts(
    String paymentAccountId,
  ) async {
    return blockDelete
        ? const PaymentAccountLinkedRecordCounts(
            incomeCount: 1,
            expenseCount: 0,
          )
        : const PaymentAccountLinkedRecordCounts(
            incomeCount: 0,
            expenseCount: 0,
          );
  }

  @override
  Future<bool> canDeletePaymentAccount(String paymentAccountId) async {
    return !blockDelete;
  }

  @override
  Future<bool> hasLinkedRecords(String paymentAccountId) async => blockDelete;

  @override
  Future<void> deletePaymentAccount(String paymentAccountId) async {
    if (blockDelete) {
      throw PaymentAccountDeleteBlockedException(
        await getLinkedRecordCounts(paymentAccountId),
      );
    }

    deletedIds.add(paymentAccountId);
  }
}

class FakeSavingGoalRepository implements SavingGoalRepository {
  FakeSavingGoalRepository(this.savingGoals);

  final List<SavingGoal> savingGoals;

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
  group('PersonalPage', () {
    testWidgets('renders payment accounts and savings options', (tester) async {
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);
      final savingGoalRepository = FakeSavingGoalRepository([_savingGoal()]);

      await tester.pumpWidget(
        _buildPersonalPage(paymentAccountRepository, savingGoalRepository),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Cuentas de pago'), findsOneWidget);
      expect(find.text('Ahorros'), findsOneWidget);
      expect(find.text('1 cuenta'), findsOneWidget);
      expect(find.text('1 meta'), findsOneWidget);
    });

    testWidgets('opens savings page when tapping savings option', (
      tester,
    ) async {
      final paymentAccountRepository = FakePaymentAccountRepository([]);
      final savingGoalRepository = FakeSavingGoalRepository([_savingGoal()]);

      await tester.pumpWidget(
        _buildPersonalPage(paymentAccountRepository, savingGoalRepository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ahorros'));
      await tester.pumpAndSettle();

      expect(find.byType(SavingsPage), findsOneWidget);
    });
  });

  group('PaymentAccountsPage', () {
    testWidgets('opens account detail when tapping an account', (tester) async {
      final repository = FakePaymentAccountRepository([_paymentAccount()]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Principal'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de cuenta'), findsOneWidget);
      expect(find.text('Banco Nacional'), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });

    testWidgets('opens account editor when swiping right', (tester) async {
      final repository = FakePaymentAccountRepository([_paymentAccount()]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _swipeRight(tester);
      await tester.pumpAndSettle();

      expect(find.text('Editar Cuenta de Pago'), findsOneWidget);
      expect(find.text('Banco Nacional'), findsOneWidget);
      expect(find.text('Principal'), findsOneWidget);
    });

    testWidgets(
      'does not delete account when swipe confirmation is cancelled',
      (tester) async {
        final repository = FakePaymentAccountRepository([_paymentAccount()]);

        await tester.pumpWidget(_buildPage(repository));
        await tester.pumpAndSettle();

        await _swipeLeft(tester);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(repository.deletedIds, isEmpty);
        expect(find.text('Principal'), findsOneWidget);
      },
    );

    testWidgets('deletes account when swipe confirmation is accepted', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository([_paymentAccount()]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _swipeLeft(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(repository.deletedIds, ['payment-account-1']);
      expect(find.text('Cuenta de pago eliminada'), findsOneWidget);
    });

    testWidgets('shows blocked delete message after swipe delete', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository([
        _paymentAccount(),
      ], blockDelete: true);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _swipeLeft(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(repository.deletedIds, isEmpty);
      expect(
        find.textContaining('No se puede eliminar esta cuenta'),
        findsOneWidget,
      );
    });
  });
}

Widget _buildPage(FakePaymentAccountRepository repository) {
  return MaterialApp(home: PaymentAccountsPage(repository: repository));
}

Widget _buildPersonalPage(
  FakePaymentAccountRepository paymentAccountRepository,
  FakeSavingGoalRepository savingGoalRepository,
) {
  return MaterialApp(
    home: PersonalPage(
      repository: paymentAccountRepository,
      savingGoalRepository: savingGoalRepository,
    ),
  );
}

PaymentAccount _paymentAccount() {
  return PaymentAccount(
    id: 'payment-account-1',
    bankName: 'Banco Nacional',
    alias: 'Principal',
    type: PaymentAccountType.debitCard,
    cardLastDigits: '1234',
    iban: 'CR05015202001026284066',
    createdAt: DateTime(2026, 4, 28),
  );
}

SavingGoal _savingGoal() {
  return SavingGoal(
    id: 'saving-goal-1',
    title: 'Laptop',
    targetAmount: 1000,
    status: SavingGoalStatus.active,
    createdAt: DateTime(2026, 4, 28),
  );
}

Future<void> _swipeRight(WidgetTester tester) async {
  await _dragAccount(tester, const Offset(120, 0));
}

Future<void> _swipeLeft(WidgetTester tester) async {
  await _dragAccount(tester, const Offset(-120, 0));
}

Future<void> _dragAccount(WidgetTester tester, Offset offset) async {
  final row = find.byWidgetPredicate(
    (widget) =>
        widget is GestureDetector && widget.onHorizontalDragUpdate != null,
  );
  await tester.drag(row.first, offset);
  await tester.pumpAndSettle();
}
