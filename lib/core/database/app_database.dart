import 'package:drift/drift.dart';

import 'database_connection.dart';
import 'incomes_table.dart';
import 'payment_accounts_table.dart';
import 'expenses_table.dart';
import 'saving_goals_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [IncomesTable, PaymentAccountsTable, ExpensesTable, SavingGoalsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  // Constructor for testing with custom connection
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        await migrator.createTable(paymentAccountsTable);
      }
      if (from < 3) {
        await migrator.createTable(expensesTable);
      }
      if (from < 4) {
        await migrator.addColumn(incomesTable, incomesTable.currency);
        if (from >= 3) {
          await migrator.addColumn(expensesTable, expensesTable.currency);
        }
      }
      if (from < 5) {
        await migrator.addColumn(incomesTable, incomesTable.paymentAccountId);
      }
      if (from < 6) {
        await migrator.createTable(savingGoalsTable);
      }
      if (from >= 2 && from < 7) {
        await migrator.addColumn(
          paymentAccountsTable,
          paymentAccountsTable.closingDayOfMonth,
        );
      }
    },
    beforeOpen: (_) async {
      await _ensureCurrencyColumn('incomes_table');
      await _ensureCurrencyColumn('expenses_table');
      await _ensureIncomePaymentAccountColumn();
      await _ensurePaymentAccountClosingDayColumn();
    },
  );

  Future<void> _ensureCurrencyColumn(String tableName) async {
    final columns = await customSelect('PRAGMA table_info($tableName)').get();
    final hasCurrency = columns.any((row) => row.data['name'] == 'currency');

    if (!hasCurrency) {
      await customStatement(
        "ALTER TABLE $tableName ADD COLUMN currency TEXT NOT NULL DEFAULT 'crc'",
      );
    }
  }

  Future<void> _ensureIncomePaymentAccountColumn() async {
    final columns = await customSelect(
      'PRAGMA table_info(incomes_table)',
    ).get();
    final hasPaymentAccountId = columns.any(
      (row) => row.data['name'] == 'payment_account_id',
    );

    if (!hasPaymentAccountId) {
      await customStatement(
        'ALTER TABLE incomes_table ADD COLUMN payment_account_id TEXT NULL',
      );
    }
  }

  Future<void> _ensurePaymentAccountClosingDayColumn() async {
    final columns = await customSelect(
      'PRAGMA table_info(payment_accounts_table)',
    ).get();
    final hasClosingDayOfMonth = columns.any(
      (row) => row.data['name'] == 'closing_day_of_month',
    );

    if (!hasClosingDayOfMonth) {
      await customStatement(
        'ALTER TABLE payment_accounts_table '
        'ADD COLUMN closing_day_of_month INTEGER NULL',
      );
    }
  }
}
