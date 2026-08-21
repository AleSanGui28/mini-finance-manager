# Mini Finance Manager - Project Analysis

**Last updated:** May 7, 2026  
**Repository:** `mini-finance-manager`  
**Primary target:** Windows desktop  
**Secondary target:** Android  
**Status:** Active development. This document reflects the current working tree, not only the last committed revision.

---

## A. Executive Summary

Mini Finance Manager is a Flutter personal finance app built around local-first persistence with Drift and SQLite. The app uses a feature-based architecture:

- `core/` contains database and theme infrastructure.
- `features/` contains Home, Incomes, Personal, Expenses, and shared domain code.
- Domain models are plain Dart classes/enums.
- Repositories translate between Drift rows and domain entities.
- UI uses standard Flutter widgets, `StreamBuilder`, and simple `Navigator.push` navigation.
- There is no backend, hosting layer, routing package, or state-management package.

Current implemented modules:

- Home dashboard.
- Incomes with add/edit/delete/detail/list support.
- Expenses with add/edit/delete/detail/list support.
- Personal, split into payment accounts and savings.
- Shared currency support for incomes and expenses.

Not implemented yet:

- Balance module.
- Reporting/filtering.
- Exchange-rate conversion.
- Account balance reconciliation.

---

## B. Repository Architecture Map

```text
mini-finance-manager/
  lib/
    app.dart
    main.dart
    core/
      database/
      theme/
    features/
      home/
      incomes/
      expenses/
      personal/
      shared/
  test/
    core/
    features/
  docs/
  pubspec.yaml
  pubspec.lock
  analysis_options.yaml
```

### Application Entry

```text
lib/main.dart
  -> runApp(const FinanceApp())

lib/app.dart
  -> MaterialApp
  -> AppTheme.light / AppTheme.dark
  -> home: HomePage
```

`FinanceApp` configures the title, disables the debug banner, applies FlexColorScheme/GoogleFonts theme settings, and opens `HomePage` as the first screen.

### Core Layer

```text
lib/core/
  database/
    app_database.dart
    app_database.g.dart
    database_connection.dart
    incomes_table.dart
    payment_accounts_table.dart
    expenses_table.dart
    saving_goals_table.dart
  theme/
    app_theme.dart
```

Core responsibilities:

- Drift database registration and migrations.
- SQLite file connection through `path_provider` and `path`.
- Table definitions.
- Generated Drift implementation.
- App theme setup.

### Feature Layer

```text
lib/features/
  shared/
    domain/
      money_currency.dart

  home/
    presentation/
      home_page.dart

  incomes/
    domain/
      income.dart
      income_category.dart
    data/
      repository/
        income_repository.dart
    presentation/
      add_income_page.dart
      income_detail_page.dart
      income_list_page.dart
      incomes_page.dart

  expenses/
    domain/
      expense.dart
      expense_type.dart
      expense_frequency.dart
      fixed_expense_category.dart
    data/
      repository/
        expense_repository.dart
    presentation/
      add_expense_page.dart
      expense_detail_page.dart
      expenses_page.dart

  personal/
    domain/
      payment_account.dart
      payment_account_type.dart
      saving_goal.dart
      saving_goal_status.dart
    data/
      repository/
        payment_account_repository.dart
        saving_goal_repository.dart
    presentation/
      add_payment_account_page.dart
      add_saving_goal_page.dart
      payment_account_detail_page.dart
      payment_accounts_page.dart
      personal_page.dart
      saving_goal_detail_page.dart
      savings_page.dart
```

The dominant pattern is:

```text
domain model/enums
  -> repository
  -> Drift table
  -> Stream<List<Entity>>
  -> StreamBuilder UI
```

---

## C. Current Implemented Modules

## Home / Dashboard

**Status:** Implemented.

Location: `lib/features/home/presentation/home_page.dart`

The dashboard creates or receives repositories for:

- `IncomeRepository`
- `PaymentAccountRepository`
- `SavingGoalRepository`
- `ExpenseRepository`

If all repositories are injected, no local database is created. If any repository is missing, `HomePage` creates one `AppDatabase` instance and closes it in `dispose()`.

Dashboard data is assembled with nested `StreamBuilder`s:

```text
watchIncomes()
  -> watchPaymentAccounts()
    -> watchSavingGoals()
      -> watchExpenses()
```

Current dashboard cards:

- `Ingresos`: total income grouped by currency and income count.
- `Personal`: payment-account count plus savings count and target total.
- `Gastos`: total expenses grouped by currency and expense count.
- Placeholder text for future modules.

Navigation:

- Incomes card opens `IncomesPage`.
- Personal card opens `PersonalPage`.
- Expenses card opens `ExpensesPage`.

Balance is not yet present on the dashboard.

## Shared Currency

**Status:** Implemented for incomes and expenses.

Location: `lib/features/shared/domain/money_currency.dart`

Implemented:

- `MoneyCurrency.crc`
- `MoneyCurrency.usd`
- label extension
- symbol extension

Incomes and expenses store currency independently. Existing summary UIs group totals by currency rather than converting or mixing currencies.

Important note: terminal output currently shows some Spanish/accented strings and the CRC symbol as mojibake. The current tests also assert the current symbol string, so encoding cleanup should be handled separately from feature work.

## Incomes

**Status:** Implemented.

Locations:

- Domain: `lib/features/incomes/domain`
- Data: `lib/features/incomes/data/repository/income_repository.dart`
- UI: `lib/features/incomes/presentation`

Implemented:

- `Income` entity with id, amount, currency, optional payment account id, category, date, createdAt, and description.
- `IncomeCategory` enum: salary, sinpe, transaction, other.
- `IncomeRepository.watchIncomes()`.
- `IncomeRepository.addIncome(...)`.
- `IncomeRepository.updateIncome(...)`.
- `IncomeRepository.deleteIncome(...)`.
- `IncomesPage` with grouped summary totals, list, empty state, add button, swipe edit/delete, and tap/long-press detail navigation.
- `IncomeDetailPage` with account/category/date/description display, edit action, and delete action.
- `AddIncomePage` supports both create and edit modes.
- `IncomeListPage` exists as a separate history screen with similar list interactions.

Business rules in the current implementation:

- Income amounts must be numeric and greater than zero in the form.
- Creating income requires a selected payment account.
- Only payment account types that can receive income are shown in `AddIncomePage`.
- Repository validation rejects missing payment accounts and accounts that cannot receive income.
- Currency defaults to CRC and is persisted as `enum.name`.

Current caveats:

- `IncomeCategory` parsing uses `firstWhere` without fallback, so corrupt category strings can throw.
- `IncomeListPage` exists, but `IncomesPage` already includes the visible income list; a separate route to `IncomeListPage` is not a central workflow.

## Expenses

**Status:** Implemented.

Locations:

- Domain: `lib/features/expenses/domain`
- Data: `lib/features/expenses/data/repository/expense_repository.dart`
- UI: `lib/features/expenses/presentation`

Implemented:

- `Expense` entity with id, amount, currency, type, payment account id, date, createdAt, optional description, fixed category, frequency, and custom frequency description.
- `ExpenseType` enum: fixed, sporadic.
- `ExpenseFrequency` enum: weekly, biweekly, monthly, yearly, custom.
- `FixedExpenseCategory` enum: services, subscriptions, memberships, other.
- `ExpenseRepository.watchExpenses()`, sorted by date descending.
- `ExpenseRepository.addExpense(...)`.
- `ExpenseRepository.updateExpense(...)`.
- `ExpenseRepository.deleteExpense(...)`.
- `ExpensesPage` with grouped summary totals, list, empty state, add button, swipe edit/delete, and tap/long-press detail navigation.
- `ExpenseDetailPage` with account/type/date/description/fixed fields display, edit action, and delete action.
- `AddExpensePage` supports both create and edit modes.

Business rules in the current implementation:

- Expense amounts must be numeric and greater than zero in the form.
- Creating/editing requires a selected payment account.
- Fixed expenses require fixed category and frequency.
- Custom frequency requires a custom frequency description.
- Sporadic expenses clear fixed-only fields.
- Currency defaults to CRC and is persisted as `enum.name`.

Current caveats:

- Expense repository does not validate that `paymentAccountId` exists before insert/update.
- There is no database-level foreign key constraint for payment-account references.

## Personal / Payment Accounts

**Status:** Implemented.

Locations:

- Domain: `lib/features/personal/domain/payment_account.dart`
- Data: `lib/features/personal/data/repository/payment_account_repository.dart`
- UI: `lib/features/personal/presentation/payment_accounts_page.dart`

Implemented:

- `PaymentAccount` entity.
- `PaymentAccountType` enum: bankAccount, debitCard, creditCard, cash, other.
- `PaymentAccountType.canReceiveIncome`.
- `PaymentAccountRepository.watchPaymentAccounts()`.
- `PaymentAccountRepository.addPaymentAccount(...)`.
- `PaymentAccountRepository.updatePaymentAccount(...)`.
- `PaymentAccountRepository.deletePaymentAccount(...)`.
- Linked-record count helpers for income/expense references.
- Delete blocking when a payment account has linked income or expense records.
- Type-change blocking when changing an account with linked incomes to a type that cannot receive income.
- `PaymentAccountsPage` list with empty state, add button, swipe edit/delete, and tap/long-press detail navigation.
- `PaymentAccountDetailPage` with edit and delete actions.
- `AddPaymentAccountPage` supports create and edit modes.

Business rules in the current implementation:

- Card data stores only optional last 4 digits.
- IBAN is optional and masked in display.
- Account type parsing falls back to `PaymentAccountType.other`.
- Credit card and other accounts cannot receive incomes.

## Personal / Savings

**Status:** Implemented.

Locations:

- Domain: `lib/features/personal/domain/saving_goal.dart`
- Data: `lib/features/personal/data/repository/saving_goal_repository.dart`
- UI: `lib/features/personal/presentation/savings_page.dart`

Implemented:

- `SavingGoal` entity with id, title, target amount, optional target date, status, createdAt, and optional updatedAt.
- `SavingGoalStatus` enum: active, frozen.
- `SavingGoalRepository.watchSavingGoals()`, sorted by createdAt descending.
- `SavingGoalRepository.addSavingGoal(...)`.
- `SavingGoalRepository.updateSavingGoal(...)`.
- `SavingGoalRepository.deleteSavingGoal(...)`.
- `freezeSavingGoal(...)` and `resumeSavingGoal(...)`.
- `SavingsPage` with total target summary, active/frozen counts, list, empty state, add button, swipe edit/delete, and tap/long-press detail navigation.
- `SavingGoalDetailPage` with freeze/resume, edit, and delete actions.
- `AddSavingGoalPage` supports create and edit modes.

Current caveats:

- Saving goals do not store currency.
- Savings are goals only; they do not currently transfer money or affect account balances.

---

## D. Database + Schema Summary

### Database Setup

Location: `lib/core/database/app_database.dart`

```dart
@DriftDatabase(
  tables: [IncomesTable, PaymentAccountsTable, ExpensesTable, SavingGoalsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 6;
}
```

Production connection:

```text
getApplicationDocumentsDirectory()
  -> app.db
  -> NativeDatabase(file)
```

### Current Schema Version

**Current schema version:** 6

Migration strategy:

- Fresh install: `migrator.createAll()`.
- Upgrade from `< 2`: create `paymentAccountsTable`.
- Upgrade from `< 3`: create `expensesTable`.
- Upgrade from `< 4`: add currency columns to incomes and expenses where applicable.
- Upgrade from `< 5`: add nullable `payment_account_id` to incomes.
- Upgrade from `< 6`: create `savingGoalsTable`.
- `beforeOpen` repairs missing currency columns and missing income payment-account column for development/legacy database states.

### Table 1: `incomes_table`

Defined in `lib/core/database/incomes_table.dart`.

```text
id                  TEXT PRIMARY KEY
amount              REAL NOT NULL
currency            TEXT NOT NULL DEFAULT 'crc'
payment_account_id  TEXT NULL
category            TEXT NOT NULL
date                DATETIME NOT NULL
description         TEXT NOT NULL DEFAULT ''
created_at          DATETIME NOT NULL
```

### Table 2: `payment_accounts_table`

Defined in `lib/core/database/payment_accounts_table.dart`.

```text
id                TEXT PRIMARY KEY
bank_name         TEXT NOT NULL
alias             TEXT NOT NULL
type              TEXT NOT NULL
created_at        DATETIME NOT NULL
card_last_digits  TEXT NULL
iban              TEXT NULL
```

### Table 3: `expenses_table`

Defined in `lib/core/database/expenses_table.dart`.

```text
id                            TEXT PRIMARY KEY
amount                        REAL NOT NULL
currency                      TEXT NOT NULL DEFAULT 'crc'
type                          TEXT NOT NULL
payment_account_id            TEXT NOT NULL
date                          DATETIME NOT NULL
created_at                    DATETIME NOT NULL
description                   TEXT NULL
fixed_category                TEXT NULL
frequency                     TEXT NULL
custom_frequency_description  TEXT NULL
```

### Table 4: `saving_goals_table`

Defined in `lib/core/database/saving_goals_table.dart`.

```text
id             TEXT PRIMARY KEY
title          TEXT NOT NULL
target_amount  REAL NOT NULL
target_date    DATETIME NULL
status         TEXT NOT NULL
created_at     DATETIME NOT NULL
updated_at     DATETIME NULL
```

### Generated Drift File

Generated file: `lib/core/database/app_database.g.dart`

This file should not be edited by hand. Regenerate it with build runner after schema changes.

### Database Constraints and Gaps

- Primary keys are defined for all tables.
- No explicit indexes are defined.
- No explicit foreign key constraints are defined.
- Payment-account linkage is enforced mostly at the repository/UI layer.
- No database-level checks prevent negative amounts.
- Enum values are stored as strings.
- Some enum parsing has fallback behavior; income category parsing is stricter and can throw on invalid stored values.

---

## E. Testing Status

Current test files:

```text
test/core/database/app_database_migration_test.dart
test/features/shared/domain/money_currency_test.dart
test/features/home/presentation/home_page_test.dart
test/features/incomes/domain/income_test.dart
test/features/incomes/data/repository/income_repository_test.dart
test/features/incomes/presentation/add_income_page_test.dart
test/features/incomes/presentation/incomes_page_test.dart
test/features/incomes/presentation/income_list_page_test.dart
test/features/expenses/domain/expense_test.dart
test/features/expenses/data/repository/expense_repository_test.dart
test/features/expenses/presentation/add_expense_page_test.dart
test/features/expenses/presentation/expenses_page_test.dart
test/features/personal/domain/payment_account_type_test.dart
test/features/personal/domain/saving_goal_status_test.dart
test/features/personal/data/repository/payment_account_repository_test.dart
test/features/personal/data/repository/saving_goal_repository_test.dart
test/features/personal/presentation/add_payment_account_page_test.dart
test/features/personal/presentation/add_saving_goal_page_test.dart
test/features/personal/presentation/payment_account_detail_page_test.dart
test/features/personal/presentation/personal_page_test.dart
test/features/personal/presentation/savings_page_test.dart
```

Coverage currently includes:

- Domain enum/model tests.
- Repository tests with in-memory Drift databases.
- Database migration tests for currency, income payment account id, and saving goals.
- Widget tests for main feature pages and forms.

Verification was not rerun during this documentation refresh.

---

## F. Dependencies

From `pubspec.yaml`:

### Production Dependencies

```yaml
flutter:
  sdk: flutter
flex_color_scheme: ^8.0.0
google_fonts: ^6.2.1
drift: ^2.18.0
sqlite3_flutter_libs: ^0.5.0
path: ^1.9.1
path_provider: ^2.1.0
uuid: ^4.0.0
cupertino_icons: ^1.0.8
```

### Dev Dependencies

```yaml
flutter_test:
  sdk: flutter
drift_dev: ^2.18.0
build_runner: ^2.4.0
flutter_lints: ^6.0.0
```

Notable current dependency state:

- `path` is now a direct dependency and is used by `database_connection.dart`.
- No routing package is present.
- No state-management package is present.
- No networking/backend dependency is present.

---

## G. Known Risks and Gaps

### Product Gaps

- Balance module is not implemented.
- No reporting, budgets, filters, or search.
- No exchange-rate settings or conversion.
- No real account balance ledger.
- Saving goals are not connected to account balances.

### Data Integrity Risks

- No foreign key constraints for payment-account references.
- Expense repository does not validate payment-account existence.
- Income category parsing can throw if stored data is invalid.
- Database-level amount constraints are absent.
- Multi-currency totals are grouped, but no conversion exists.

### UI / Text Risks

- Some Spanish labels and currency symbols appear mojibake-encoded in terminal output.
- Several UI strings are hardcoded; there is no localization system.
- Savings display target totals without currency.

### Architecture Risks

- Summary total calculation is duplicated in multiple UI files.
- Nested `StreamBuilder`s are simple and acceptable for now, but derived dashboards can become harder to maintain as modules grow.
- Payment-account linkage rules are spread across repositories and UI forms.

---

## H. Suggested Next Implementation Step

The safest next implementation step is the Balance feature requested for the next phase.

Recommended direction:

1. Create a new feature folder:

```text
lib/features/balance/
  domain/
  presentation/
```

2. Keep Balance read-only and derived from existing streams:

```text
IncomeRepository.watchIncomes()
ExpenseRepository.watchExpenses()
```

3. Do not add a database table, route package, state-management package, or dependency.

4. Compute totals by currency:

```text
Balance = Total Incomes - Total Expenses
```

5. Avoid mixing currencies. CRC and USD balances should be separate unless exchange-rate conversion is explicitly added later.

6. Add:

- Balance summary/card on `HomePage`.
- `BalancePage` detail screen.
- Pure domain calculator/status classes to avoid duplicating balance math in presentation.
- Tests for positive, negative, zero, empty, and multi-currency balance cases.

This keeps the app aligned with its current architecture and avoids premature dependencies.

---

## I. Working Context for Future Tasks

Preserve these constraints unless explicitly changed:

- Offline-first, local-only app.
- Windows desktop first, Android later.
- Drift + SQLite persistence.
- Feature-based structure.
- Shared code in `lib/core` or `lib/features/shared` when appropriate.
- Database code in `lib/core/database`.
- No backend or hosting.
- No routing package unless explicitly requested.
- No state-management package unless explicitly requested.
- Prefer `StreamBuilder` and repository streams for current scope.
- Use generated Drift files only to understand schema; do not edit them manually.
- Use English for code and comments.
- UI labels can be Spanish.
