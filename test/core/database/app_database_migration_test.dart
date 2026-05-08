import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/core/database/app_database.dart';

void main() {
  group('AppDatabase migrations', () {
    test(
      'version 3 data defaults income and expense currency to crc',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'mini_finance_manager_test_',
        );
        final file = File('${tempDir.path}/migration_test.sqlite');

        final database = AppDatabase.test(
          NativeDatabase(
            file,
            setup: (database) {
              database
                ..execute('''
                CREATE TABLE incomes_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  amount REAL NOT NULL,
                  category TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  description TEXT NOT NULL DEFAULT '',
                  created_at INTEGER NOT NULL
                )
              ''')
                ..execute('''
                CREATE TABLE payment_accounts_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  bank_name TEXT NOT NULL,
                  alias TEXT NOT NULL,
                  type TEXT NOT NULL,
                  card_last_digits TEXT NULL,
                  iban TEXT NULL,
                  created_at INTEGER NOT NULL
                )
              ''')
                ..execute('''
                CREATE TABLE expenses_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  amount REAL NOT NULL,
                  type TEXT NOT NULL,
                  payment_account_id TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  created_at INTEGER NOT NULL,
                  description TEXT NULL,
                  fixed_category TEXT NULL,
                  frequency TEXT NULL,
                  custom_frequency_description TEXT NULL
                )
              ''')
                ..execute('''
                INSERT INTO incomes_table (
                  id, amount, category, date, description, created_at
                ) VALUES (
                  'income-1', 100.0, 'salary', 0, 'Existing income', 0
                )
              ''')
                ..execute('''
                INSERT INTO expenses_table (
                  id, amount, type, payment_account_id, date, created_at,
                  description, fixed_category, frequency,
                  custom_frequency_description
                ) VALUES (
                  'expense-1', 25.0, 'sporadic', 'account-1', 0, 0,
                  'Existing expense', NULL, NULL, NULL
                )
              ''')
                ..execute('PRAGMA user_version = 3');
            },
          ),
        );

        try {
          final incomeRows = await database
              .customSelect('SELECT currency FROM incomes_table')
              .get();
          final expenseRows = await database
              .customSelect('SELECT currency FROM expenses_table')
              .get();

          expect(incomeRows.single.data['currency'], 'crc');
          expect(expenseRows.single.data['currency'], 'crc');
        } finally {
          await database.close();
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'version 4 data adds nullable income payment account column',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'mini_finance_manager_test_',
        );
        final file = File('${tempDir.path}/migration_test.sqlite');

        final database = AppDatabase.test(
          NativeDatabase(
            file,
            setup: (database) {
              database
                ..execute('''
                CREATE TABLE incomes_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  amount REAL NOT NULL,
                  category TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  description TEXT NOT NULL DEFAULT '',
                  created_at INTEGER NOT NULL
                )
              ''')
                ..execute('''
                CREATE TABLE payment_accounts_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  bank_name TEXT NOT NULL,
                  alias TEXT NOT NULL,
                  type TEXT NOT NULL,
                  card_last_digits TEXT NULL,
                  iban TEXT NULL,
                  created_at INTEGER NOT NULL
                )
              ''')
                ..execute('''
                CREATE TABLE expenses_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  amount REAL NOT NULL,
                  type TEXT NOT NULL,
                  payment_account_id TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  created_at INTEGER NOT NULL,
                  description TEXT NULL,
                  fixed_category TEXT NULL,
                  frequency TEXT NULL,
                  custom_frequency_description TEXT NULL
                )
              ''')
                ..execute('''
                INSERT INTO incomes_table (
                  id, amount, category, date, description, created_at
                ) VALUES (
                  'income-1', 100.0, 'salary', 0, 'Existing income', 0
                )
              ''')
                ..execute('''
                INSERT INTO expenses_table (
                  id, amount, type, payment_account_id, date, created_at,
                  description, fixed_category, frequency,
                  custom_frequency_description
                ) VALUES (
                  'expense-1', 25.0, 'sporadic', 'account-1', 0, 0,
                  'Existing expense', NULL, NULL, NULL
                )
              ''')
                ..execute('PRAGMA user_version = 4');
            },
          ),
        );

        try {
          final incomeRows = await database
              .customSelect('SELECT currency FROM incomes_table')
              .get();
          final expenseRows = await database
              .customSelect('SELECT currency FROM expenses_table')
              .get();
          final incomePaymentAccountRows = await database
              .customSelect('SELECT payment_account_id FROM incomes_table')
              .get();

          expect(incomeRows.single.data['currency'], 'crc');
          expect(expenseRows.single.data['currency'], 'crc');
          expect(
            incomePaymentAccountRows.single.data['payment_account_id'],
            isNull,
          );
        } finally {
          await database.close();
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'version 5 data missing income payment account column is repaired on open',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'mini_finance_manager_test_',
        );
        final file = File('${tempDir.path}/migration_test.sqlite');

        final database = AppDatabase.test(
          NativeDatabase(
            file,
            setup: (database) {
              database
                ..execute('''
                CREATE TABLE incomes_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  amount REAL NOT NULL,
                  currency TEXT NOT NULL DEFAULT 'crc',
                  category TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  description TEXT NOT NULL DEFAULT '',
                  created_at INTEGER NOT NULL
                )
              ''')
                ..execute('''
                CREATE TABLE payment_accounts_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  bank_name TEXT NOT NULL,
                  alias TEXT NOT NULL,
                  type TEXT NOT NULL,
                  card_last_digits TEXT NULL,
                  iban TEXT NULL,
                  created_at INTEGER NOT NULL
                )
              ''')
                ..execute('''
                CREATE TABLE expenses_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  amount REAL NOT NULL,
                  currency TEXT NOT NULL DEFAULT 'crc',
                  type TEXT NOT NULL,
                  payment_account_id TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  created_at INTEGER NOT NULL,
                  description TEXT NULL,
                  fixed_category TEXT NULL,
                  frequency TEXT NULL,
                  custom_frequency_description TEXT NULL
                )
              ''')
                ..execute('''
                INSERT INTO incomes_table (
                  id, amount, currency, category, date, description, created_at
                ) VALUES (
                  'income-1', 100.0, 'crc', 'salary', 0, 'Existing income', 0
                )
              ''')
                ..execute('PRAGMA user_version = 5');
            },
          ),
        );

        try {
          final rows = await database
              .customSelect('SELECT payment_account_id FROM incomes_table')
              .get();

          expect(rows.single.data['payment_account_id'], isNull);
        } finally {
          await database.close();
          await tempDir.delete(recursive: true);
        }
      },
    );

    test('version 5 data creates saving goals table on upgrade', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'mini_finance_manager_test_',
      );
      final file = File('${tempDir.path}/migration_test.sqlite');

      final database = AppDatabase.test(
        NativeDatabase(
          file,
          setup: (database) {
            database
              ..execute('''
                CREATE TABLE incomes_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  amount REAL NOT NULL,
                  currency TEXT NOT NULL DEFAULT 'crc',
                  payment_account_id TEXT NULL,
                  category TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  description TEXT NOT NULL DEFAULT '',
                  created_at INTEGER NOT NULL
                )
              ''')
              ..execute('''
                CREATE TABLE payment_accounts_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  bank_name TEXT NOT NULL,
                  alias TEXT NOT NULL,
                  type TEXT NOT NULL,
                  card_last_digits TEXT NULL,
                  iban TEXT NULL,
                  created_at INTEGER NOT NULL
                )
              ''')
              ..execute('''
                CREATE TABLE expenses_table (
                  id TEXT NOT NULL PRIMARY KEY,
                  amount REAL NOT NULL,
                  currency TEXT NOT NULL DEFAULT 'crc',
                  type TEXT NOT NULL,
                  payment_account_id TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  created_at INTEGER NOT NULL,
                  description TEXT NULL,
                  fixed_category TEXT NULL,
                  frequency TEXT NULL,
                  custom_frequency_description TEXT NULL
                )
              ''')
              ..execute('PRAGMA user_version = 5');
          },
        ),
      );

      try {
        final tableRows = await database
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' "
              "AND name = 'saving_goals_table'",
            )
            .get();

        expect(tableRows, hasLength(1));
      } finally {
        await database.close();
        await tempDir.delete(recursive: true);
      }
    });
  });
}
