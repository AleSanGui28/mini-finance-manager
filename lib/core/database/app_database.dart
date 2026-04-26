import 'package:drift/drift.dart';

import 'database_connection.dart';
import 'incomes_table.dart';
import 'payment_accounts_table.dart';
import 'expenses_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [IncomesTable, PaymentAccountsTable, ExpensesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  // Constructor for testing with custom connection
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 3;

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
    },
  );
}
