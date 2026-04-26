---
applyTo: "**/*.dart"
---

# Flutter and Drift Instructions

Use these patterns in this repository.

## Flutter

- Prefer simple widgets before abstractions.
- Keep widgets maintainable.
- Dispose controllers properly.
- Prefer StreamBuilder with Drift streams.

## Drift

When schema changes:

1. Update table files
2. Update AppDatabase
3. Increase schemaVersion
4. Run build_runner
5. Then run analyze

Never manually edit generated files:

- \*.g.dart

Store enums using:
enum.name

## Verification

Run commands one at a time:

dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test

Do not use flutter run as automated verification.

## Codex command behavior

- Use extended timeouts
- Do not run commands in parallel
- Timeout alone does not imply code failure
- Retry once before reporting timeout
