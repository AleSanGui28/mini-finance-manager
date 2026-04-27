---
applyTo: "lib/core/database/**/*.dart"
---

# Drift Database Instructions

This project uses Drift with SQLite for local offline persistence.

## General Rules

- Never manually edit generated files.
- Generated files include:
  - *.g.dart

- Keep each table in a separate file when possible.
- Table classes should end in `Table`.
- Keep naming consistent with existing patterns.

Examples:

- incomes_table.dart
- payment_accounts_table.dart
- expenses_table.dart

## Schema Design Rules

Store enum values using:

- `enum.name`

When reading enums from database:

- Map safely back to enum values.
- Provide fallback defaults if needed.

Example:

- unknown enum value -> fallback to `other`

Additional rules:

- Use nullable columns only when the business field is optional.
- Prefer one normalized table per aggregate unless explicitly requested.

## Schema Change Workflow

Whenever changing database schema:

1. Create or update table files.

2. Update:

- `app_database.dart`

3. Increase:

- `schemaVersion`

4. Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. Then run:

```bash
flutter analyze
```

Order matters.

Never run analyze before build_runner after schema changes.

## Repository Pattern Rules

Repositories should generally expose:

- watch* streams
- add*
- update* when needed
- delete* when needed

Examples:

- watchExpenses()
- addExpense()

Use Drift streams with StreamBuilder unless explicitly requested otherwise.

## Development Migration Rule

If schema changes break the local development database
and production migration is not being implemented yet:

Deleting the local development database is acceptable.

Do not implement complex migrations unless explicitly requested.

## Verification

Preferred verification commands:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Run commands one at a time.

Do not run them in parallel.

## Codex Execution Rules

- Use extended timeouts for build_runner and analyze.
- Retry once before treating timeout as failure.
- Timeout alone does not imply code failure.

