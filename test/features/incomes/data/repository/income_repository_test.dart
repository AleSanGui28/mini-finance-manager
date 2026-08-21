import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/core/database/app_database.dart';
import 'package:mini_finance_manager/features/incomes/data/repository/income_repository.dart';
import 'package:mini_finance_manager/features/incomes/domain/income.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

// Helper to create an in-memory database for testing
AppDatabase createTestDatabase() {
  return AppDatabase.test(NativeDatabase.memory());
}

void main() {
  group('IncomeRepository', () {
    late AppDatabase database;
    late IncomeRepository repository;

    setUp(() async {
      // Create in-memory database for testing
      database = createTestDatabase();
      repository = IncomeRepository(database);
      await _insertPaymentAccount(database);
    });

    tearDown(() async {
      // Close database after each test
      await database.close();
    });

    test('addIncome inserts income into database', () async {
      // Arrange
      const amount = 1500.0;
      final category = IncomeCategory.salary;
      final date = DateTime(2026, 4, 23);
      const description = 'Monthly salary';

      // Act
      await repository.addIncome(
        amount: amount,
        category: category,
        paymentAccountId: 'payment-account-1',
        date: date,
        description: description,
      );

      // Assert - Get incomes stream and check
      final incomes = await repository.watchIncomes().first;
      expect(incomes.length, equals(1));
      expect(incomes.first.amount, equals(amount));
      expect(incomes.first.category, equals(category));
      expect(incomes.first.paymentAccountId, 'payment-account-1');
      expect(incomes.first.description, equals(description));
    });

    test('addIncome generates unique IDs', () async {
      // Act
      await repository.addIncome(
        amount: 1000,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime.now(),
        description: 'Income 1',
      );

      await repository.addIncome(
        amount: 2000,
        category: IncomeCategory.sinpe,
        paymentAccountId: 'payment-account-1',
        date: DateTime.now(),
        description: 'Income 2',
      );

      // Assert
      final incomes = await repository.watchIncomes().first;
      expect(incomes.length, equals(2));
      expect(incomes[0].id, isNotEmpty);
      expect(incomes[1].id, isNotEmpty);
      expect(incomes[0].id, isNot(equals(incomes[1].id)));
    });

    test('watchIncomes returns all added incomes', () async {
      // Arrange
      const income1 = {'amount': 1500.0, 'category': IncomeCategory.salary};
      const income2 = {'amount': 500.0, 'category': IncomeCategory.sinpe};
      const income3 = {'amount': 250.0, 'category': IncomeCategory.other};

      // Act
      await repository.addIncome(
        amount: income1['amount'] as double,
        category: income1['category'] as IncomeCategory,
        paymentAccountId: 'payment-account-1',
        date: DateTime.now(),
        description: '',
      );

      await repository.addIncome(
        amount: income2['amount'] as double,
        category: income2['category'] as IncomeCategory,
        paymentAccountId: 'payment-account-1',
        date: DateTime.now(),
        description: '',
      );

      await repository.addIncome(
        amount: income3['amount'] as double,
        category: income3['category'] as IncomeCategory,
        paymentAccountId: 'payment-account-1',
        date: DateTime.now(),
        description: '',
      );

      // Assert
      final incomes = await repository.watchIncomes().first;
      expect(incomes.length, equals(3));
    });

    test('watchIncomes returns stream that updates', () async {
      // Act
      final stream = repository.watchIncomes();

      // First listen - should be empty
      final first = await stream.first;
      expect(first.length, equals(0));

      // Add income
      await repository.addIncome(
        amount: 1000,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime.now(),
        description: 'Test',
      );

      // Second listen - should have one income
      final second = await stream.first;
      expect(second.length, equals(1));
    });

    test('addIncome stores all income properties correctly', () async {
      // Arrange
      final date = DateTime(2026, 4, 15);
      final now = DateTime.now();
      const amount = 2500.50;
      const description = 'Freelance work completed';

      // Act
      await repository.addIncome(
        amount: amount,
        category: IncomeCategory.transaction,
        paymentAccountId: 'payment-account-1',
        date: date,
        description: description,
      );

      // Assert
      final incomes = await repository.watchIncomes().first;
      final income = incomes.first;

      expect(income.amount, equals(amount));
      expect(income.paymentAccountId, 'payment-account-1');
      expect(income.category, equals(IncomeCategory.transaction));
      expect(income.date, equals(date));
      expect(income.description, equals(description));
      expect(income.id, isNotEmpty);
      expect(
        income.createdAt.isBefore(now.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('addIncome stores default colones currency in database', () async {
      await repository.addIncome(
        amount: 500,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 27),
        description: '',
      );

      final rows = await database.select(database.incomesTable).get();
      expect(rows.single.currency, 'crc');
    });

    test('addIncome stores and maps dollar currency', () async {
      await repository.addIncome(
        amount: 500,
        currency: MoneyCurrency.usd,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 27),
        description: '',
      );

      final rows = await database.select(database.incomesTable).get();
      expect(rows.single.currency, 'usd');

      final incomes = await repository.watchIncomes().first;
      expect(incomes.single.currency, MoneyCurrency.usd);
    });

    test('addIncome stores and maps payment account id', () async {
      await repository.addIncome(
        amount: 500,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 27),
        description: '',
      );

      final rows = await database.select(database.incomesTable).get();
      expect(rows.single.paymentAccountId, 'payment-account-1');

      final incomes = await repository.watchIncomes().first;
      expect(incomes.single.paymentAccountId, 'payment-account-1');
    });

    test('addIncome rejects accounts that cannot receive income', () async {
      for (final type in [
        PaymentAccountType.creditCard,
        PaymentAccountType.other,
      ]) {
        await _insertPaymentAccount(
          database,
          id: '${type.name}-account',
          type: type,
        );

        expect(
          () => repository.addIncome(
            amount: 500,
            category: IncomeCategory.salary,
            paymentAccountId: '${type.name}-account',
            date: DateTime(2026, 4, 27),
            description: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      }
    });

    test('addIncome with empty description', () async {
      // Act
      await repository.addIncome(
        amount: 500,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime.now(),
        description: '',
      );

      // Assert
      final incomes = await repository.watchIncomes().first;
      expect(incomes.first.description, isEmpty);
    });

    test('addIncome with all category types', () async {
      // Act
      for (final category in IncomeCategory.values) {
        await repository.addIncome(
          amount: 100,
          category: category,
          paymentAccountId: 'payment-account-1',
          date: DateTime.now(),
          description: '',
        );
      }

      // Assert
      final incomes = await repository.watchIncomes().first;
      expect(incomes.length, equals(IncomeCategory.values.length));

      for (int i = 0; i < IncomeCategory.values.length; i++) {
        expect(incomes[i].category, equals(IncomeCategory.values[i]));
      }
    });

    test('multiple addIncome calls work sequentially', () async {
      // Act
      for (int i = 0; i < 5; i++) {
        await repository.addIncome(
          amount: 100 * (i + 1).toDouble(),
          category: IncomeCategory.salary,
          paymentAccountId: 'payment-account-1',
          date: DateTime.now(),
          description: 'Income $i',
        );
      }

      // Assert
      final incomes = await repository.watchIncomes().first;
      expect(incomes.length, equals(5));

      for (int i = 0; i < 5; i++) {
        expect(incomes[i].amount, equals(100 * (i + 1).toDouble()));
      }
    });

    test('watchIncomes preserves data between calls', () async {
      // Arrange
      await repository.addIncome(
        amount: 1000,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime.now(),
        description: 'Test 1',
      );

      // Act
      final first = await repository.watchIncomes().first;
      final second = await repository.watchIncomes().first;

      // Assert
      expect(first.length, equals(1));
      expect(second.length, equals(1));
      expect(first.first.id, equals(second.first.id));
    });

    test('updateIncome updates an existing income', () async {
      await repository.addIncome(
        amount: 1000,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 1),
        description: 'Original income',
      );

      final income = (await repository.watchIncomes().first).single;

      await repository.updateIncome(
        Income(
          id: income.id,
          amount: 1500,
          currency: MoneyCurrency.usd,
          paymentAccountId: 'payment-account-1',
          category: IncomeCategory.sinpe,
          date: DateTime(2026, 4, 2),
          createdAt: income.createdAt,
          description: 'Updated income',
        ),
      );

      final updatedIncome = (await repository.watchIncomes().first).single;
      expect(updatedIncome.id, income.id);
      expect(updatedIncome.amount, 1500);
      expect(updatedIncome.currency, MoneyCurrency.usd);
      expect(updatedIncome.paymentAccountId, 'payment-account-1');
      expect(updatedIncome.category, IncomeCategory.sinpe);
      expect(updatedIncome.date, DateTime(2026, 4, 2));
      expect(updatedIncome.description, 'Updated income');
      expect(updatedIncome.createdAt, income.createdAt);
    });

    test('deleteIncome removes an existing income', () async {
      await repository.addIncome(
        amount: 1000,
        category: IncomeCategory.salary,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 1),
        description: 'Income to delete',
      );

      final income = (await repository.watchIncomes().first).single;

      await repository.deleteIncome(income.id);

      final incomes = await repository.watchIncomes().first;
      expect(incomes, isEmpty);
    });

    test('watchIncomes maps invalid stored currency to colones', () async {
      await database
          .into(database.incomesTable)
          .insert(
            IncomesTableCompanion.insert(
              id: 'income-1',
              amount: 500,
              currency: const drift.Value('invalid'),
              category: IncomeCategory.salary.name,
              date: DateTime(2026, 4, 27),
              createdAt: DateTime(2026, 4, 27),
            ),
          );

      final incomes = await repository.watchIncomes().first;
      expect(incomes.single.currency, MoneyCurrency.crc);
    });
  });
}

Future<void> _insertPaymentAccount(
  AppDatabase database, {
  String id = 'payment-account-1',
  PaymentAccountType type = PaymentAccountType.cash,
}) {
  return database
      .into(database.paymentAccountsTable)
      .insert(
        PaymentAccountsTableCompanion.insert(
          id: id,
          bankName: 'Wallet',
          alias: 'Cash',
          type: type.name,
          createdAt: DateTime(2026, 4, 28),
        ),
      );
}
