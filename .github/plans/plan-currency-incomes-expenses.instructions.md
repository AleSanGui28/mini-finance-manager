# Plan: Currency Support for Incomes and Expenses

**TL;DR:** Add a currency field to incomes and expenses so each record can be saved as Colones or Dollars. Do not convert currencies in this first version; display and total them separately to avoid mixing CRC and USD.

## Assumptions

- Each income and expense stores its own currency.
- Supported currencies are Colones and Dollars.
- Existing records should default to Colones during migration.
- Totals should be grouped by currency, not converted.
- Exchange-rate conversion is out of scope for this phase.

## Steps

### Phase 1: Domain Layer

1. Create a shared currency enum, probably `MoneyCurrency`.
   - Values: `crc`, `usd`
   - Labels: `Colones`, `Dollars`
   - Symbols: `₡`, `$`
2. Add a `currency` field to `Income`.
3. Add a `currency` field to `Expense`.

### Phase 2: Database Layer

4. Add a `currency` text column to `IncomesTable`.
5. Add a `currency` text column to `ExpensesTable`.
6. Increase `AppDatabase.schemaVersion` from `3` to `4`.
7. Add migration logic for existing databases.
   - Add `currency` to `incomesTable` with default `crc`.
   - Add `currency` to `expensesTable` with default `crc`.

### Phase 3: Repository Layer

8. Update `IncomeRepository.addIncome()` to accept and persist currency.
9. Update `IncomeRepository.updateIncome()` to persist currency.
10. Update income row mapping to read currency.
11. Update `ExpenseRepository.addExpense()` to accept and persist currency.
12. Update expense row mapping to read currency.
13. Add safe parsing fallback to `crc` if stored currency is missing or invalid.

### Phase 4: Income UI

14. Add a currency selector to `AddIncomePage`.
   - Put it near the amount field.
   - Default to Colones for new incomes.
   - Preselect saved currency when editing.
15. Pass selected currency when creating or updating an income.
16. Update income displays to use the record currency symbol:
   - `IncomesPage`
   - `IncomeDetailPage`
   - `IncomeListPage`

### Phase 5: Expense UI

17. Add a currency selector to `AddExpensePage`.
   - Put it near the amount field.
   - Default to Colones for new expenses.
18. Pass selected currency when creating an expense.
19. Update expense displays to use the record currency symbol:
   - `ExpensesPage`

### Phase 6: Totals

20. Update income totals to group by currency.
   - Show CRC total.
   - Show USD total when present.
21. Update expense totals to group by currency.
   - Show CRC total.
   - Show USD total when present.
22. Update `HomePage` cards to show grouped totals.
   - If only one currency exists, show one total.
   - If both currencies exist, show both totals.

### Phase 7: Tests

23. Add or update repository tests.
   - Income can be saved with CRC.
   - Income can be saved with USD.
   - Expense can be saved with CRC.
   - Expense can be saved with USD.
   - Existing data defaults to CRC after migration.
24. Add or update widget tests.
   - Income form renders currency selector.
   - Income edit mode preselects saved currency.
   - Expense form renders currency selector.
   - Lists and detail pages render the correct symbol.
   - Totals are grouped by currency.

## Relevant Files

- `lib/features/shared/domain/money_currency.dart` — create shared enum
- `lib/features/incomes/domain/income.dart` — add currency
- `lib/features/expenses/domain/expense.dart` — add currency
- `lib/core/database/incomes_table.dart` — add currency column
- `lib/core/database/expenses_table.dart` — add currency column
- `lib/core/database/app_database.dart` — schema version and migration
- `lib/core/database/app_database.g.dart` — regenerate with build runner
- `lib/features/incomes/data/repository/income_repository.dart` — read/write currency
- `lib/features/expenses/data/repository/expense_repository.dart` — read/write currency
- `lib/features/incomes/presentation/add_income_page.dart` — currency selector
- `lib/features/expenses/presentation/add_expense_page.dart` — currency selector
- `lib/features/incomes/presentation/incomes_page.dart` — grouped totals and display
- `lib/features/incomes/presentation/income_detail_page.dart` — display currency
- `lib/features/incomes/presentation/income_list_page.dart` — display currency
- `lib/features/expenses/presentation/expenses_page.dart` — grouped totals and display
- `lib/features/home/presentation/home_page.dart` — grouped income and expense totals

## Verification

1. Create income in Colones and confirm it displays with `₡`.
2. Create income in Dollars and confirm it displays with `$`.
3. Create expense in Colones and confirm it displays with `₡`.
4. Create expense in Dollars and confirm it displays with `$`.
5. Confirm income totals do not mix currencies.
6. Confirm expense totals do not mix currencies.
7. Confirm home cards show one or two totals depending on recorded currencies.
8. Confirm existing records still appear as Colones after migration.
9. Run `dart run build_runner build --delete-conflicting-outputs`.
10. Run `flutter test`.
11. Run `flutter analyze`.

## Out of Scope

- Exchange-rate lookup.
- Manual exchange-rate settings.
- Converting all totals into one base currency.
- Multi-currency payment account balances.
