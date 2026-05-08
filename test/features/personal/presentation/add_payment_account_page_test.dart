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
  }) async {
    addedAccounts.add({
      'bankName': bankName,
      'alias': alias,
      'type': type,
      'cardLastDigits': cardLastDigits,
      'iban': iban,
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
