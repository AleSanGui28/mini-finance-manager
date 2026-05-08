# Plan: Edit & Delete Existing Income

**TL;DR:** Add `update()` and `delete()` methods to IncomeRepository, create a detail page for displaying single incomes, modify AddIncomePage to support edit mode (with field pre-population), and add swipe/tap interactions to IncomeListPage with a delete confirmation dialog.

## Steps

### Phase 1: Data Layer (Database & Repository)

1. Add `updateIncome()` to IncomeRepository — maps Income entity to Drift update
2. Add `deleteIncome()` to IncomeRepository — deletes by ID
   - _(No schema changes needed; existing table supports this)_

### Phase 2: Presentation Layer - Detail Page

_(depends on Phase 1)_ 3. Create new `IncomeDetailPage` — displays single income with Edit & Delete buttons

- Shows amount, category, date, description
- Edit button navigates to AddIncomePage with income
- Delete button shows confirmation dialog

### Phase 3: Presentation Layer - Edit Form

_(depends on Phase 1)_ 4. Modify `AddIncomePage` to support both create and edit modes

- Add optional `income` constructor parameter (null = create)
- Pre-populate fields if editing
- Adjust UI labels ("Add Income" vs "Save Income")
- Call `updateIncome()` or `addIncome()` based on mode

### Phase 4: Presentation Layer - List Interactions

_(depends on Phases 2 & 3)_ 5. Modify `IncomeListPage` to enable editing/deleting

- Add swipe actions (Dismissible) for quick delete
- Add tap/long-press to open IncomeDetailPage
- Show delete confirmation before calling `deleteIncome()`
- StreamBuilder automatically rebuilds on changes

## Relevant Files

- `lib/features/incomes/data/repository/income_repository.dart` — Add updateIncome() and deleteIncome()
- `lib/features/incomes/presentation/add_income_page.dart` — Modify for edit mode
- `lib/features/incomes/presentation/income_list_page.dart` — Add interactions
- `lib/features/incomes/presentation/income_detail_page.dart` — **CREATE NEW**
- `lib/features/incomes/domain/income.dart` — No changes needed

## Verification

1. Repository methods test: Add income → Update fields → Delete → Verify in list
2. Navigation test: Tap income in list → Detail page shows correct data
3. Edit flow: Click Edit on detail → AddIncomePage pre-populated → Save changes → List updates
4. Delete flow: Swipe to delete → Confirmation dialog → Delete → Income removed
5. No regressions: IncomesPage stays unaffected (read-only, reflects totals)

## Decisions

- **IncomeListPage only** receives edit/delete (IncomesPage remains read-only summary view)
- **Reuse AddIncomePage** for both create and edit modes (minimizes code duplication)
- **Separate detail page** accessed via tap (swipe action reserved for quick delete)
- **Delete confirmation required** to prevent accidental data loss
- **No database schema changes** — existing IncomesTable supports edit/delete

## Architecture Notes

### Pattern: Repository Layer

- `watchIncomes()` — Stream of all incomes (existing)
- `addIncome()` — Create new income (existing)
- **`updateIncome(Income)`** — Update existing income by ID
- **`deleteIncome(String id)`** — Delete income by ID
- `_mapRowToIncome()` — Convert Drift row to domain entity (existing)

### Pattern: Detail Page

- Stateless widget receiving `IncomeRepository` and `Income`
- Displays formatted income data (amount, category, date, description)
- Two action buttons: Edit, Delete
- Edit navigates to AddIncomePage with income
- Delete shows confirmation dialog with "Confirm" and "Cancel" options

### Pattern: Add/Edit Form

- Constructor parameter: `Income? income` (null = create, non-null = edit)
- Initialize TextEditingControllers based on income parameter
- Form labels and button text change based on mode
- Validation logic remains identical for both modes

### Pattern: List with Swipe & Tap

- Each income card wrapped in `Dismissible` (swipe left = delete)
- Tap on card navigates to IncomeDetailPage
- Delete confirmation shown before removal
- StreamBuilder watches `repository.watchIncomes()` for automatic rebuilds
