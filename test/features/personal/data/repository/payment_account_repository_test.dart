import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/core/database/app_database.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_type.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';

void main() {
  group('PaymentAccountRepository', () {
    late AppDatabase database;
    late PaymentAccountRepository repository;

    setUp(() {
      database = AppDatabase.test(NativeDatabase.memory());
      repository = PaymentAccountRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('addPaymentAccount inserts account into database', () async {
      await repository.addPaymentAccount(
        bankName: 'Banco Nacional',
        alias: 'Principal',
        type: PaymentAccountType.bankAccount,
        iban: 'CR05015202001026284066',
      );

      final accounts = await repository.watchPaymentAccounts().first;

      expect(accounts, hasLength(1));
      expect(accounts.single.id, isNotEmpty);
      expect(accounts.single.bankName, 'Banco Nacional');
      expect(accounts.single.alias, 'Principal');
      expect(accounts.single.type, PaymentAccountType.bankAccount);
      expect(accounts.single.iban, 'CR05015202001026284066');
    });

    test(
      'updatePaymentAccount updates editable fields and preserves identity',
      () async {
        final createdAt = DateTime(2026, 4, 28);
        await _insertPaymentAccount(database, createdAt: createdAt);

        await repository.updatePaymentAccount(
          PaymentAccount(
            id: 'payment-account-1',
            bankName: 'Banco Popular',
            alias: 'Gastos diarios',
            type: PaymentAccountType.debitCard,
            cardLastDigits: '1234',
            iban: 'CR05015202001026284066',
            createdAt: createdAt,
          ),
        );

        final updatedAccount =
            (await repository.watchPaymentAccounts().first).single;

        expect(updatedAccount.id, 'payment-account-1');
        expect(updatedAccount.createdAt, createdAt);
        expect(updatedAccount.bankName, 'Banco Popular');
        expect(updatedAccount.alias, 'Gastos diarios');
        expect(updatedAccount.type, PaymentAccountType.debitCard);
        expect(updatedAccount.cardLastDigits, '1234');
        expect(updatedAccount.iban, 'CR05015202001026284066');
      },
    );

    test('updatePaymentAccount clears optional card and iban values', () async {
      final createdAt = DateTime(2026, 4, 28);
      await _insertPaymentAccount(
        database,
        type: PaymentAccountType.debitCard,
        cardLastDigits: '9876',
        iban: 'CR05015202001026284066',
        createdAt: createdAt,
      );

      await repository.updatePaymentAccount(
        PaymentAccount(
          id: 'payment-account-1',
          bankName: 'Wallet',
          alias: 'Cash',
          type: PaymentAccountType.cash,
          createdAt: createdAt,
        ),
      );

      final updatedAccount =
          (await repository.watchPaymentAccounts().first).single;

      expect(updatedAccount.type, PaymentAccountType.cash);
      expect(updatedAccount.cardLastDigits, isNull);
      expect(updatedAccount.iban, isNull);
    });

    test('deletePaymentAccount removes an unlinked account', () async {
      await _insertPaymentAccount(database);

      await repository.deletePaymentAccount('payment-account-1');

      final accounts = await repository.watchPaymentAccounts().first;
      expect(accounts, isEmpty);
    });

    test('deletePaymentAccount is blocked when linked to incomes', () async {
      await _insertPaymentAccount(database);
      await _insertIncome(database, paymentAccountId: 'payment-account-1');

      expect(
        () => repository.deletePaymentAccount('payment-account-1'),
        throwsA(isA<PaymentAccountDeleteBlockedException>()),
      );

      final accounts = await repository.watchPaymentAccounts().first;
      expect(accounts, hasLength(1));
    });

    test('deletePaymentAccount is blocked when linked to expenses', () async {
      await _insertPaymentAccount(database);
      await _insertExpense(database, paymentAccountId: 'payment-account-1');

      expect(
        () => repository.deletePaymentAccount('payment-account-1'),
        throwsA(isA<PaymentAccountDeleteBlockedException>()),
      );

      final accounts = await repository.watchPaymentAccounts().first;
      expect(accounts, hasLength(1));
    });

    test('linked record counts include incomes and expenses', () async {
      await _insertPaymentAccount(database);
      await _insertIncome(
        database,
        id: 'income-1',
        paymentAccountId: 'payment-account-1',
      );
      await _insertIncome(
        database,
        id: 'income-2',
        paymentAccountId: 'payment-account-1',
      );
      await _insertExpense(database, paymentAccountId: 'payment-account-1');

      final counts = await repository.getLinkedRecordCounts(
        'payment-account-1',
      );

      expect(counts.incomeCount, 2);
      expect(counts.expenseCount, 1);
      expect(counts.hasLinkedRecords, isTrue);
      expect(
        await repository.canDeletePaymentAccount('payment-account-1'),
        isFalse,
      );
      expect(await repository.hasLinkedRecords('payment-account-1'), isTrue);
    });

    test(
      'type change to non-income account is blocked when incomes are linked',
      () async {
        final createdAt = DateTime(2026, 4, 28);
        await _insertPaymentAccount(
          database,
          type: PaymentAccountType.bankAccount,
          createdAt: createdAt,
        );
        await _insertIncome(database, paymentAccountId: 'payment-account-1');

        expect(
          () => repository.updatePaymentAccount(
            PaymentAccount(
              id: 'payment-account-1',
              bankName: 'Banco Nacional',
              alias: 'Principal',
              type: PaymentAccountType.creditCard,
              createdAt: createdAt,
            ),
          ),
          throwsA(isA<PaymentAccountTypeChangeBlockedException>()),
        );

        final account = (await repository.watchPaymentAccounts().first).single;
        expect(account.type, PaymentAccountType.bankAccount);
      },
    );
  });
}

Future<void> _insertPaymentAccount(
  AppDatabase database, {
  String id = 'payment-account-1',
  PaymentAccountType type = PaymentAccountType.cash,
  String? cardLastDigits,
  String? iban,
  DateTime? createdAt,
}) {
  return database
      .into(database.paymentAccountsTable)
      .insert(
        PaymentAccountsTableCompanion.insert(
          id: id,
          bankName: 'Wallet',
          alias: 'Cash',
          type: type.name,
          cardLastDigits: drift.Value(cardLastDigits),
          iban: drift.Value(iban),
          createdAt: createdAt ?? DateTime(2026, 4, 28),
        ),
      );
}

Future<void> _insertIncome(
  AppDatabase database, {
  String id = 'income-1',
  required String paymentAccountId,
}) {
  return database
      .into(database.incomesTable)
      .insert(
        IncomesTableCompanion.insert(
          id: id,
          amount: 500,
          paymentAccountId: drift.Value(paymentAccountId),
          category: IncomeCategory.salary.name,
          date: DateTime(2026, 4, 28),
          createdAt: DateTime(2026, 4, 28),
        ),
      );
}

Future<void> _insertExpense(
  AppDatabase database, {
  String id = 'expense-1',
  required String paymentAccountId,
}) {
  return database
      .into(database.expensesTable)
      .insert(
        ExpensesTableCompanion.insert(
          id: id,
          amount: 250,
          type: ExpenseType.sporadic.name,
          paymentAccountId: paymentAccountId,
          date: DateTime(2026, 4, 28),
          createdAt: DateTime(2026, 4, 28),
        ),
      );
}
