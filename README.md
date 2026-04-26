# Mini Finance Manager

Personal finance manager built with Flutter.

## Tech Stack

- Flutter
- Dart
- Drift ORM
- SQLite
- Clean Architecture

## Current Features

- Incomes module
- Local persistence with SQLite
- Windows desktop support
- Android support planned

## Run locally

```bash
flutter pub get
flutter run -d windows
```

## Code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Quality checks

```bash
flutter analyze
flutter test
flutter build windows
```
