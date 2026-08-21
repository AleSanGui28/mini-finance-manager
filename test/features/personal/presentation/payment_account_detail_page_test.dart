import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/personal/presentation/payment_account_detail_page.dart';

class FakePaymentAccountRepository implements PaymentAccountRepository {
  FakePaymentAccountRepository({this.blockDelete = false});

  final bool blockDelete;
  final deletedIds = <String>[];
  PaymentAccount? updatedAccount;

  @override
  Stream<List<PaymentAccount>> watchPaymentAccounts() => Stream.value([]);

  @override
  Future<void> addPaymentAccount({
    required String bankName,
    required String alias,
    required PaymentAccountType type,
    String? cardLastDigits,
    String? iban,
    int? closingDayOfMonth,
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
            expenseCount: 1,
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

void main() {
  group('PaymentAccountDetailPage', () {
    testWidgets('renders account details with masked values', (tester) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));

      expect(find.text('Detalle de cuenta'), findsOneWidget);
      expect(find.text('Principal'), findsWidgets);
      expect(find.text('Banco Nacional'), findsOneWidget);
      expect(find.text('**** 1234'), findsOneWidget);
      expect(find.textContaining('4066'), findsOneWidget);
      expect(find.textContaining('CR05015202001026284066'), findsNothing);
    });

    testWidgets('renders credit card billing details', (tester) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(
        _buildPage(
          repository,
          paymentAccount: _paymentAccount(
            type: PaymentAccountType.creditCard,
            closingDayOfMonth: 25,
          ),
        ),
      );

      expect(find.text('Fecha de corte'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('Rango de pago'), findsOneWidget);
      expect(find.text('del 25 al 10 del siguiente mes'), findsOneWidget);
    });

    testWidgets('does not delete when confirmation is cancelled', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));

      await _tapDeleteButton(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repository.deletedIds, isEmpty);
      expect(find.text('Detalle de cuenta'), findsOneWidget);
    });

    testWidgets('deletes account when confirmation is accepted', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));

      await _tapDeleteButton(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(repository.deletedIds, ['payment-account-1']);
    });

    testWidgets('shows a clear message when delete is blocked', (tester) async {
      final repository = FakePaymentAccountRepository(blockDelete: true);

      await tester.pumpWidget(_buildPage(repository));

      await _tapDeleteButton(tester);
      await tester.pumpAndSettle();
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

Widget _buildPage(
  FakePaymentAccountRepository repository, {
  PaymentAccount? paymentAccount,
}) {
  return MaterialApp(
    home: PaymentAccountDetailPage(
      repository: repository,
      paymentAccount: paymentAccount ?? _paymentAccount(),
    ),
  );
}

PaymentAccount _paymentAccount({
  PaymentAccountType type = PaymentAccountType.debitCard,
  int? closingDayOfMonth,
}) {
  return PaymentAccount(
    id: 'payment-account-1',
    bankName: 'Banco Nacional',
    alias: 'Principal',
    type: type,
    closingDayOfMonth: closingDayOfMonth,
    cardLastDigits: '1234',
    iban: 'CR05015202001026284066',
    createdAt: DateTime(2026, 4, 28),
  );
}

Future<void> _tapDeleteButton(WidgetTester tester) async {
  final deleteButton = find.widgetWithText(OutlinedButton, 'Eliminar');
  await tester.ensureVisible(deleteButton);
  await tester.pumpAndSettle();
  await tester.tap(deleteButton);
}
