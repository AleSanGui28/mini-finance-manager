import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/personal/presentation/add_payment_account_page.dart';

class FakePaymentAccountRepository implements PaymentAccountRepository {
  final addedAccounts = <Map<String, dynamic>>[];
  PaymentAccount? updatedAccount;
  final deletedIds = <String>[];

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
  }) async {
    addedAccounts.add({
      'bankName': bankName,
      'alias': alias,
      'type': type,
      'cardLastDigits': cardLastDigits,
      'iban': iban,
      'closingDayOfMonth': closingDayOfMonth,
    });
  }

  @override
  Future<void> updatePaymentAccount(PaymentAccount paymentAccount) async {
    updatedAccount = paymentAccount;
  }

  @override
  Future<PaymentAccountLinkedRecordCounts> getLinkedRecordCounts(
    String paymentAccountId,
  ) async {
    return const PaymentAccountLinkedRecordCounts(
      incomeCount: 0,
      expenseCount: 0,
    );
  }

  @override
  Future<bool> canDeletePaymentAccount(String paymentAccountId) async => true;

  @override
  Future<bool> hasLinkedRecords(String paymentAccountId) async => false;

  @override
  Future<void> deletePaymentAccount(String paymentAccountId) async {
    deletedIds.add(paymentAccountId);
  }
}

void main() {
  group('AddPaymentAccountPage', () {
    testWidgets('saves a new payment account', (tester) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Banco Nacional',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Principal');
      await _tapSave(tester);
      await tester.pumpAndSettle();

      expect(repository.addedAccounts.single['bankName'], 'Banco Nacional');
      expect(repository.addedAccounts.single['alias'], 'Principal');
      expect(
        repository.addedAccounts.single['type'],
        PaymentAccountType.bankAccount,
      );
    });

    testWidgets('edit mode pre-fills and preserves id and createdAt', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository();
      final createdAt = DateTime(2026, 4, 28);
      final account = PaymentAccount(
        id: 'payment-account-1',
        bankName: 'Banco Nacional',
        alias: 'Principal',
        type: PaymentAccountType.debitCard,
        cardLastDigits: '1234',
        iban: 'CR05015202001026284066',
        createdAt: createdAt,
      );

      await tester.pumpWidget(_buildPage(repository, paymentAccount: account));

      expect(find.text('Editar Cuenta de Pago'), findsOneWidget);
      expect(find.text('Banco Nacional'), findsOneWidget);
      expect(find.text('Principal'), findsOneWidget);
      expect(find.text('1234'), findsWidgets);

      await tester.enterText(find.byType(TextFormField).at(0), 'Banco Popular');
      await tester.enterText(find.byType(TextFormField).at(1), 'Diaria');
      await _tapSave(tester);
      await tester.pumpAndSettle();

      expect(repository.updatedAccount?.id, 'payment-account-1');
      expect(repository.updatedAccount?.createdAt, createdAt);
      expect(repository.updatedAccount?.bankName, 'Banco Popular');
      expect(repository.updatedAccount?.alias, 'Diaria');
      expect(repository.updatedAccount?.type, PaymentAccountType.debitCard);
      expect(repository.updatedAccount?.cardLastDigits, '1234');
      expect(repository.updatedAccount?.iban, 'CR05015202001026284066');
    });

    testWidgets('validates card last digits when provided', (tester) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));

      await tester.tap(
        find.byType(DropdownButtonFormField<PaymentAccountType>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(PaymentAccountType.debitCard.label).last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Banco Nacional',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Principal');
      await tester.enterText(find.byType(TextFormField).at(2), '12');
      await _tapSave(tester);
      await tester.pump();

      expect(find.textContaining('exactamente 4'), findsOneWidget);
      expect(repository.addedAccounts, isEmpty);
    });

    testWidgets('shows closing day selector only for credit cards', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      expect(find.text('Fecha de corte *'), findsNothing);

      await _selectAccountType(tester, PaymentAccountType.creditCard);

      expect(find.text('Fecha de corte *'), findsOneWidget);
      expect(find.text('Rango de pago calculado'), findsOneWidget);
    });

    testWidgets('updates payment range preview from closing day', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _selectAccountType(tester, PaymentAccountType.creditCard);
      await _selectClosingDay(tester, 25);

      expect(
        find.text('Rango de pago: del 25 al 10 del siguiente mes'),
        findsOneWidget,
      );
    });

    testWidgets('requires closing day for credit cards', (tester) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _selectAccountType(tester, PaymentAccountType.creditCard);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Banco Nacional',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Tarjeta');
      await _tapSave(tester);
      await tester.pump();

      expect(find.text('Selecciona una fecha de corte'), findsWidgets);
      expect(repository.addedAccounts, isEmpty);
    });

    testWidgets('saves selected closing day for credit cards', (tester) async {
      final repository = FakePaymentAccountRepository();

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _selectAccountType(tester, PaymentAccountType.creditCard);
      await _selectClosingDay(tester, 3);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Banco Nacional',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Tarjeta');
      await _tapSave(tester);
      await tester.pumpAndSettle();

      expect(
        repository.addedAccounts.single['type'],
        PaymentAccountType.creditCard,
      );
      expect(repository.addedAccounts.single['closingDayOfMonth'], 3);
    });

    testWidgets('edit mode pre-fills credit card billing information', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository();
      final account = PaymentAccount(
        id: 'payment-account-1',
        bankName: 'Banco Nacional',
        alias: 'Tarjeta',
        type: PaymentAccountType.creditCard,
        cardLastDigits: '1234',
        closingDayOfMonth: 25,
        createdAt: DateTime(2026, 4, 28),
      );

      await tester.pumpWidget(_buildPage(repository, paymentAccount: account));
      await tester.pumpAndSettle();

      expect(find.text('Fecha de corte *'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(
        find.text('Rango de pago: del 25 al 10 del siguiente mes'),
        findsOneWidget,
      );
    });

    testWidgets('changing away from credit card clears closing day', (
      tester,
    ) async {
      final repository = FakePaymentAccountRepository();
      final account = PaymentAccount(
        id: 'payment-account-1',
        bankName: 'Banco Nacional',
        alias: 'Tarjeta',
        type: PaymentAccountType.creditCard,
        closingDayOfMonth: 25,
        createdAt: DateTime(2026, 4, 28),
      );

      await tester.pumpWidget(_buildPage(repository, paymentAccount: account));
      await tester.pumpAndSettle();

      await _selectAccountType(tester, PaymentAccountType.cash);
      await _tapSave(tester);
      await tester.pumpAndSettle();

      expect(repository.updatedAccount?.type, PaymentAccountType.cash);
      expect(repository.updatedAccount?.closingDayOfMonth, isNull);
    });
  });
}

Widget _buildPage(
  FakePaymentAccountRepository repository, {
  PaymentAccount? paymentAccount,
}) {
  return MaterialApp(
    home: AddPaymentAccountPage(
      repository: repository,
      paymentAccount: paymentAccount,
    ),
  );
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(ElevatedButton));
  await tester.tap(find.byType(ElevatedButton));
}

Future<void> _selectAccountType(
  WidgetTester tester,
  PaymentAccountType type,
) async {
  await tester.tap(find.byType(DropdownButtonFormField<PaymentAccountType>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(type.label).last);
  await tester.pumpAndSettle();
}

Future<void> _selectClosingDay(WidgetTester tester, int day) async {
  await tester.tap(find.byType(DropdownButtonFormField<int>));
  await tester.pumpAndSettle();

  final dayFinder = find.text('$day');
  for (
    var attempt = 0;
    attempt < 5 && dayFinder.evaluate().isEmpty;
    attempt++
  ) {
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -300));
    await tester.pumpAndSettle();
  }

  await tester.tap(find.text('$day').last);
  await tester.pumpAndSettle();
}
