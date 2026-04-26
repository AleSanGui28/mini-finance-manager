# Mini Finance Manager - Project Analysis

**Last updated:** April 26, 2026  
**Repository:** `mini-finance-manager`  
**Primary target:** Windows desktop  
**Secondary target:** Android  
**Status:** Active development. Incomes and Personal are implemented; Expenses has domain/data support but only placeholder UI.

---

## A. Executive Summary

Mini Finance Manager is a Flutter personal finance application built around local-first persistence with Drift and SQLite. The project follows a feature-based clean architecture style:

- `core/` contains shared database and theme infrastructure.
- `features/` contains Home, Incomes, Personal, and Expenses modules.
- Domain models are plain Dart classes/enums.
- Repositories translate between Drift rows and domain entities.
- UI uses Flutter widgets, `StreamBuilder`, and Drift streams.
- Navigation is simple `Navigator.push` with `MaterialPageRoute`.
- There is no backend, hosting layer, routing package, or state-management package.

The previous analysis file was partially stale. The current code has schema version 3 and three tables, but older sections still said schema version 1 and one table. The current repo also has tests under `test/`, so the old "test folder empty" note is no longer accurate.

No source code, generated code, dependencies, or migrations were changed during this analysis refresh.

---

## B. Repository Architecture Map

### Root-Level Files

```text
mini-finance-manager/
  lib/
  test/
  android/
  windows/
  ios/
  macos/
  linux/
  web/
  pubspec.yaml
  pubspec.lock
  analysis_options.yaml
  README.md
  COMMANDS.md
  TESTING_GUIDELINES.md
  PROJECT_ANALYSIS.md
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

[lib/main.dart](lib/main.dart) is minimal and only starts the app.  
[lib/app.dart](lib/app.dart) configures `MaterialApp`, disables the debug banner, applies theme settings, and sets [HomePage](lib/features/home/presentation/home_page.dart) as the first screen.

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
  theme/
    app_theme.dart
```

Core responsibilities:

- Drift database registration and migrations.
- SQLite file connection using `path_provider`.
- Table definitions.
- Generated Drift implementation.
- Material 3/FlexColorScheme theming.

### Feature Layer

```text
lib/features/
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
      income_list_page.dart
      incomes_page.dart

  personal/
    domain/
      payment_account.dart
      payment_account_type.dart
    data/
      repository/
        payment_account_repository.dart
    presentation/
      add_payment_account_page.dart
      personal_page.dart

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
      expenses_page.dart
```

The intended pattern is:

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

Location: [lib/features/home/presentation/home_page.dart](lib/features/home/presentation/home_page.dart)

The dashboard shows three module cards:

- Ingresos / Incomes: total amount and count.
- Cuentas de Pago / Payment Accounts: account count.
- Gastos / Expenses: total amount and count.

The page creates one `AppDatabase` in `initState`, then creates repositories unless repositories are injected through the constructor. This allows some test injection, but the current tests do not inject all repositories.

Dashboard data is assembled with nested `StreamBuilder`s:

```text
IncomeRepository.watchIncomes()
  -> PaymentAccountRepository.watchPaymentAccounts()
    -> ExpenseRepository.watchExpenses()
```

Navigation:

- Incomes card opens `IncomesPage(repository: _incomeRepository)`.
- Personal card opens `PersonalPage(repository: _paymentAccountRepository)`.
- Expenses card opens `const ExpensesPage()`.

Important mismatch: the dashboard does not pass `ExpenseRepository` into `ExpensesPage`, because `ExpensesPage` currently has no repository dependency.

## Incomes

**Status:** Mostly implemented.

Locations:

- Domain: [lib/features/incomes/domain](lib/features/incomes/domain)
- Data: [lib/features/incomes/data/repository/income_repository.dart](lib/features/incomes/data/repository/income_repository.dart)
- UI: [lib/features/incomes/presentation](lib/features/incomes/presentation)

Implemented:

- `Income` entity with id, amount, category, date, createdAt, description.
- `IncomeCategory` enum with labels: salary, sinpe, transaction, other.
- `IncomeRepository.watchIncomes()`.
- `IncomeRepository.addIncome(...)`.
- `IncomesPage` with summary total, list, empty state, and floating add button.
- `AddIncomePage` with amount/category/date/description form.
- `IncomeListPage` exists as a separate history page.

Notable details:

- Amount validation exists in `AddIncomePage` and rejects invalid, zero, and negative values.
- Repository stores enum values as `.name` strings.
- `IncomeRepository` does not catch invalid category strings when mapping rows; a bad DB value would throw.
- `IncomeListPage` exists but is not currently reachable from `IncomesPage`; the previous analysis said there was a "Ver historial" button, but the current code does not include it.
- Current repository methods are add/watch only, not full CRUD.

## Personal / Payment Accounts

**Status:** Implemented.

Locations:

- Domain: [lib/features/personal/domain](lib/features/personal/domain)
- Data: [lib/features/personal/data/repository/payment_account_repository.dart](lib/features/personal/data/repository/payment_account_repository.dart)
- UI: [lib/features/personal/presentation](lib/features/personal/presentation)

Implemented:

- `PaymentAccount` entity.
- `PaymentAccountType` enum with labels: bankAccount, debitCard, creditCard, cash, other.
- `PaymentAccountRepository.watchPaymentAccounts()`.
- `PaymentAccountRepository.addPaymentAccount(...)`.
- `PersonalPage` with list and empty state.
- `AddPaymentAccountPage` with type, bank/entity, alias, optional last digits, and optional IBAN.

Notable details:

- The repository falls back to `PaymentAccountType.other` if the stored enum string is invalid.
- `PersonalPage` accepts an optional repository, but creates a new `AppDatabase` if one is not injected.
- Current repository methods are add/watch only, not full CRUD.
- Some UI text in the source appears mojibake-encoded in terminal output in certain shells, but the source itself contains Spanish text and accented labels.

## Expenses

**Status:** Partial.

Locations:

- Domain: [lib/features/expenses/domain](lib/features/expenses/domain)
- Data: [lib/features/expenses/data/repository/expense_repository.dart](lib/features/expenses/data/repository/expense_repository.dart)
- UI: [lib/features/expenses/presentation/expenses_page.dart](lib/features/expenses/presentation/expenses_page.dart)

Implemented:

- `Expense` entity.
- `ExpenseType` enum: fixed, sporadic.
- `ExpenseFrequency` enum: weekly, biweekly, monthly, yearly, custom.
- `FixedExpenseCategory` enum: services, subscriptions, memberships, other.
- `ExpenseRepository.watchExpenses()`, sorted by date descending.
- `ExpenseRepository.addExpense(...)`.
- `ExpensesPage` placeholder screen.

Incomplete:

- No expenses list UI.
- No add-expense form.
- No account picker.
- No validation for fixed/sporadic-specific fields.
- No display of fixed category, frequency, or payment account details.
- No navigation from expenses page to an add form.
- No tests for expenses.

Important inconsistency: `Expense.type` is currently a `String`, even though `ExpenseType` exists. The repository validates the stored string but maps it back to a string instead of the enum. This weakens the domain model and should be corrected before building more expenses UI.

---

## D. Database + Schema Summary

### Database Setup

Location: [lib/core/database](lib/core/database)

The database is registered in [app_database.dart](lib/core/database/app_database.dart):

```dart
@DriftDatabase(tables: [IncomesTable, PaymentAccountsTable, ExpensesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 3;
}
```

The production connection is created in [database_connection.dart](lib/core/database/database_connection.dart):

```text
getApplicationDocumentsDirectory()
  -> app.db
  -> NativeDatabase(file)
```

The test constructor accepts a custom executor and is used by repository tests with `NativeDatabase.memory()`.

### Current Schema Version

**Current schema version:** 3

Migration strategy:

- Fresh install: `migrator.createAll()`.
- Upgrade from `< 2`: create `paymentAccountsTable`.
- Upgrade from `< 3`: create `expensesTable`.

### Table 1: `incomes_table`

Defined in [incomes_table.dart](lib/core/database/incomes_table.dart).

```text
id           TEXT PRIMARY KEY
amount       REAL NOT NULL
category     TEXT NOT NULL
date         DATETIME NOT NULL
description  TEXT NOT NULL DEFAULT ''
created_at   DATETIME NOT NULL
```

Domain enum values stored in `category`:

- `salary`
- `sinpe`
- `transaction`
- `other`

### Table 2: `payment_accounts_table`

Defined in [payment_accounts_table.dart](lib/core/database/payment_accounts_table.dart).

```text
id                TEXT PRIMARY KEY
bank_name         TEXT NOT NULL
alias             TEXT NOT NULL
type              TEXT NOT NULL
created_at        DATETIME NOT NULL
card_last_digits  TEXT NULL
iban              TEXT NULL
```

Domain enum values stored in `type`:

- `bankAccount`
- `debitCard`
- `creditCard`
- `cash`
- `other`

### Table 3: `expenses_table`

Defined in [expenses_table.dart](lib/core/database/expenses_table.dart).

```text
id                            TEXT PRIMARY KEY
amount                        REAL NOT NULL
type                          TEXT NOT NULL
payment_account_id            TEXT NOT NULL
date                          DATETIME NOT NULL
created_at                    DATETIME NOT NULL
description                   TEXT NULL
fixed_category                TEXT NULL
frequency                     TEXT NULL
custom_frequency_description  TEXT NULL
```

Domain enum values stored in `type`:

- `fixed`
- `sporadic`

Domain enum values stored in `fixed_category`:

- `services`
- `subscriptions`
- `memberships`
- `other`

Domain enum values stored in `frequency`:

- `weekly`
- `biweekly`
- `monthly`
- `yearly`
- `custom`

### Generated Drift File

Generated file: [lib/core/database/app_database.g.dart](lib/core/database/app_database.g.dart)

The generated file matches the three current table definitions and exposes:

- `$IncomesTableTable`
- `$PaymentAccountsTableTable`
- `$ExpensesTableTable`
- `IncomesTableData`
- `PaymentAccountsTableData`
- `ExpensesTableData`
- Drift companions and table managers

This file should not be edited by hand. Regenerate only after schema changes.

### Database Constraints and Gaps

- Primary keys are defined for all tables.
- No explicit indexes are defined.
- No foreign key constraint is defined for `expenses_table.payment_account_id`.
- No database-level checks prevent negative amounts.
- Enum values are stored as strings without database-level constraints.
- Delete/update repository methods are not currently implemented.

---

## E. Missing / Incomplete Areas

### Implementation Gaps

- Expenses UI is still a stub.
- Expenses domain should use `ExpenseType` instead of `String` for `Expense.type`.
- Expenses page does not receive repositories from Home.
- No add-expense page exists.
- No expense history/detail page exists.
- No edit/delete operations exist for incomes, payment accounts, or expenses.
- No filtering/reporting exists yet.
- No settings/currency configuration exists.
- No localization setup exists; strings are hardcoded.

### Repository Pattern Gaps

Current repositories expose:

```text
IncomeRepository:
  watchIncomes()
  addIncome(...)

PaymentAccountRepository:
  watchPaymentAccounts()
  addPaymentAccount(...)

ExpenseRepository:
  watchExpenses()
  addExpense(...)
```

The old analysis described these as full CRUD repositories, but the current code only supports create + watch/read streams.

### Navigation Gaps

- Navigation is simple and appropriate for the current app size.
- There are no named routes, deep links, or route guards.
- `IncomeListPage` is present but unreachable.
- Expenses navigation only reaches a placeholder page.

### Testing Gaps

Current test files exist:

```text
test/features/home/presentation/home_page_test.dart
test/features/incomes/domain/income_test.dart
test/features/incomes/data/repository/income_repository_test.dart
test/features/incomes/presentation/add_income_page_test.dart
```

Coverage gaps:

- No tests for Personal/payment accounts.
- No tests for Expenses.
- No tests for database migrations.
- No integration tests.
- Home tests appear stale relative to the current dashboard, because the dashboard now has three cards.

Verification attempts during the April 26, 2026 analysis refresh:

- `flutter analyze` timed out after 120 seconds with no usable output.
- `flutter test --no-pub` timed out after 180 seconds with no usable output.
- `flutter test --no-pub test/features/incomes/domain/income_test.dart` timed out after 60 seconds with no usable output.

Because of those timeouts, current analyzer/test health is not confirmed.

### Dependency and Project Hygiene Gaps

- `database_connection.dart` imports `package:path/path.dart`, but `path` is not listed as a direct dependency in `pubspec.yaml`. It is present transitively in `pubspec.lock`, but the direct import should usually be backed by a direct dependency.
- `pubspec.yaml` uses loose caret constraints; `pubspec.lock` currently resolves newer versions than the minimum constraints, for example Drift 2.32.1 and FlexColorScheme 8.4.0.
- `cupertino_icons` is listed but does not appear central to the current UI.
- Some generated platform plugin registrant files were already modified in the working tree before this documentation refresh.

### Database Lifecycle Risks

- `HomePage` creates an `AppDatabase` but does not close it.
- `PersonalPage` can create its own `AppDatabase` when no repository is injected.
- Tests that instantiate `HomePage` without injected repositories may touch real platform/database initialization paths.

### Data Integrity Risks

- Expense account references are plain strings with no enforced FK.
- Income enum parsing can throw if corrupt/legacy category data exists.
- Payment-account enum parsing has fallback behavior, but Income and Expenses are not fully consistent.
- There are no domain-level value objects or shared validation helpers for money amounts.

---

## F. Suggested Next Implementation Step

The safest next implementation step is to complete the Expenses feature using the existing Incomes and Personal patterns, without introducing routing or state-management dependencies.

Recommended order:

1. Tighten the Expenses domain contract.
   - Change `Expense.type` from `String` to `ExpenseType`.
   - Keep enum-string persistence inside `ExpenseRepository`.
   - Add safe enum parsing similar to `PaymentAccountRepository`.

2. Pass dependencies into `ExpensesPage`.
   - `ExpenseRepository` for expenses.
   - `PaymentAccountRepository` for payment-account selection/display.
   - Continue using constructor injection.

3. Build the first real Expenses UI.
   - Expense list sorted by date descending.
   - Summary total.
   - Empty state.
   - Floating action button to add an expense.

4. Add `AddExpensePage`.
   - Amount validation.
   - Type selector: fixed/sporadic.
   - Payment account selector.
   - Date picker.
   - Optional description.
   - Fixed-only fields: fixed category and frequency.
   - Custom frequency description when frequency is custom.

5. Add focused tests.
   - Expense domain tests.
   - Expense repository tests with in-memory Drift.
   - Widget tests for `ExpensesPage` and `AddExpensePage`.
   - Refresh stale Home tests to inject all repositories and expect three dashboard cards.

This keeps the app aligned with its current architecture and avoids premature dependencies.

---

## Current Dependency Summary

From [pubspec.yaml](pubspec.yaml):

### Production Dependencies

```yaml
flutter:
  sdk: flutter
flex_color_scheme: ^8.0.0
google_fonts: ^6.2.1
drift: ^2.18.0
sqlite3_flutter_libs: ^0.5.0
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

### Locked Versions Observed

`pubspec.lock` currently resolves:

- `drift` 2.32.1
- `drift_dev` 2.32.1
- `build_runner` 2.14.0
- `flex_color_scheme` 8.4.0
- `google_fonts` 6.3.3
- `path_provider` 2.1.5
- `sqlite3_flutter_libs` 0.5.42
- `uuid` 4.5.3

---

## Working Context for Future Tasks

Preserve these constraints unless explicitly changed:

- Offline-first, local-only app.
- Windows desktop first, Android later.
- Drift + SQLite persistence.
- Feature-based / clean architecture.
- Minimal dependencies.
- No backend or hosting.
- No routing package unless explicitly requested.
- No state-management package unless explicitly requested.
- Prefer `StreamBuilder` + repository streams for current scope.
- Use generated Drift files only to understand schema; do not edit them manually.

Primary near-term product direction:

```text
Make Expenses a real module:
  domain consistency
  repository mapping
  add/list UI
  account linkage
  focused tests
```

