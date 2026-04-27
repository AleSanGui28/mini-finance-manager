# Flutter Testing Guidelines - Mini Finance Manager

This document provides a comprehensive testing strategy for the Mini Finance Manager Flutter app, including testing practices, patterns, and guidelines for both current and future development.

---

## Table of Contents

1. [Overview](#overview)
2. [Test Structure](#test-structure)
3. [Testing Strategy by Layer](#testing-strategy-by-layer)
4. [How to Run Tests](#how-to-run-tests)
5. [Test Patterns & Best Practices](#test-patterns--best-practices)
6. [Domain Layer Testing](#domain-layer-testing)
7. [Data Layer Testing](#data-layer-testing)
8. [Presentation Layer Testing](#presentation-layer-testing)
9. [Common Testing Scenarios](#common-testing-scenarios)
10. [Guidelines for New Features](#guidelines-for-new-features)
11. [Troubleshooting](#troubleshooting)

---

## Overview

### Testing Pyramid

```
        ╔════════════════╗
        ║  Widget Tests  ║  (Few, but comprehensive)
        ║  (UI + Flow)   ║
        ╠════════════════╣
        ║  Data Tests    ║  (Multiple, database/repo)
        ║  (Repositories)║
        ╠════════════════╣
        ║  Unit Tests    ║  (Many, fast, focused)
        ║  (Models/Logic)║
        ╚════════════════╝
```

### Benefits

- **Unit Tests** (Bottom) - Fast, focused, catch logic errors early
- **Data Tests** (Middle) - Verify persistence layer works correctly
- **Widget Tests** (Top) - Ensure UI renders and responds correctly

---

## Test Structure

### Folder Organization

```
test/
├── features/
│   ├── incomes/
│   │   ├── domain/
│   │   │   └── income_test.dart
│   │   ├── presentation/
│   │   │   ├── add_income_page_test.dart
│   │   │   └── incomes_page_test.dart
│   │   └── data/
│   │       └── repository/
│   │           └── income_repository_test.dart
│   └── home/
│       └── presentation/
│           └── home_page_test.dart
└── core/
    └── database/
        └── app_database_test.dart
```

### Naming Convention

- Test files: `{source_file}_test.dart`
- Test groups: `group('ClassName', () { ... })`
- Test cases: `test('describes what should happen', () { ... })`
- Widget tests: `testWidgets('describes user interaction', (tester) { ... })`

---

## Testing Strategy by Layer

### Domain Layer ✅

**Goal:** Verify business logic and data models work correctly

- ✅ Model creation with valid data
- ✅ Edge cases (empty strings, zero values, large numbers)
- ✅ Enum mappings and extensions
- ✅ Property accessibility

**Tools:** `flutter_test` with `test()` and `group()`

### Data Layer ✅

**Goal:** Verify data persistence and repository operations

- ✅ CRUD operations (Create, Read)
- ✅ Stream emissions
- ✅ Data transformation/mapping
- ✅ Error handling

**Tools:** In-memory Drift database, `flutter_test`

### Presentation Layer ✅

**Goal:** Verify UI renders correctly and responds to interactions

- ✅ Widget rendering
- ✅ Form validation
- ✅ Navigation
- ✅ User interactions (taps, typing)

**Tools:** `testWidgets()`, `WidgetTester`, mocks

---

## How to Run Tests

### Run All Tests

```bash
flutter test
```

**Expected Output:**

```
00:01 +20: All tests passed!
```

### Run Tests for a Specific Feature

```bash
flutter test test/features/incomes/
```

### Run a Specific Test File

```bash
flutter test test/features/incomes/domain/income_test.dart
```

### Run Tests with Verbose Output

```bash
flutter test -v
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

This generates a `coverage/lcov.info` file showing test coverage.

### Run Tests in Watch Mode (Continuous)

```bash
flutter test --watch
```

The test runner will rerun tests when files change.

---

## Test Patterns & Best Practices

### AAA Pattern (Arrange-Act-Assert)

Every test should follow this structure:

```dart
test('should do something', () {
  // Arrange - Set up test data and dependencies
  final mockRepo = MockRepository();
  const testAmount = 1500.0;

  // Act - Execute the code being tested
  final result = mockRepo.addIncome(amount: testAmount);

  // Assert - Verify the result
  expect(result, isNotNull);
  expect(mockRepo.incomesAdded.length, equals(1));
});
```

### Descriptive Test Names

✅ **Good:** `test('should show error when amount is negative', ...)`  
❌ **Bad:** `test('test validation', ...)`

### Focused Tests

Each test should test ONE thing:

✅ **Good:**

```dart
test('validates amount', () { /* test amount validation */ });
test('validates category', () { /* test category validation */ });
```

❌ **Bad:**

```dart
test('validates form', () {
  /* test amount, category, date, description all in one */
});
```

### Use Groups for Organization

```dart
group('Income Model', () {
  group('Creation', () {
    test('creates income with required fields', () { ... });
    test('creates income with empty description', () { ... });
  });

  group('Validation', () {
    test('rejects negative amount', () { ... });
    test('rejects invalid category', () { ... });
  });
});
```

### Mocking Dependencies

For widget tests that depend on repositories:

```dart
class MockIncomeRepository implements IncomeRepository {
  List<Income> incomesAdded = [];

  @override
  Future<void> addIncome({...}) async {
    incomesAdded.add(Income(...));
  }

  @override
  Stream<List<Income>> watchIncomes() {
    return Stream.value(incomesAdded);
  }
}
```

---

## Domain Layer Testing

### Testing Models

```dart
test('creates Income with all fields', () {
  // Arrange
  const id = 'income-1';
  const amount = 1500.0;
  final category = IncomeCategory.salary;
  final date = DateTime(2026, 4, 23);

  // Act
  final income = Income(
    id: id,
    amount: amount,
    category: category,
    date: date,
    createdAt: DateTime.now(),
    description: 'Test',
  );

  // Assert
  expect(income.id, equals(id));
  expect(income.amount, equals(amount));
  expect(income.category, equals(category));
});
```

### Testing Enums

```dart
test('all categories have non-empty labels', () {
  for (final category in IncomeCategory.values) {
    expect(category.label, isNotEmpty);
  }
});

test('all categories have unique labels', () {
  final labels = IncomeCategory.values.map((c) => c.label).toList();
  final uniqueLabels = labels.toSet();
  expect(labels.length, equals(uniqueLabels.length));
});
```

### Testing Edge Cases

```dart
test('creates income with zero amount', () {
  final income = Income(
    id: 'id',
    amount: 0,
    category: IncomeCategory.salary,
    date: DateTime.now(),
    createdAt: DateTime.now(),
    description: '',
  );
  expect(income.amount, equals(0));
});

test('creates income with large amount', () {
  final income = Income(
    id: 'id',
    amount: 999999.99,
    category: IncomeCategory.salary,
    date: DateTime.now(),
    createdAt: DateTime.now(),
    description: '',
  );
  expect(income.amount, equals(999999.99));
});
```

---

## Data Layer Testing

### Testing Repository with In-Memory Database

```dart
group('IncomeRepository', () {
  late AppDatabase database;
  late IncomeRepository repository;

  setUp(() async {
    database = AppDatabase(); // Uses in-memory database for tests
    repository = IncomeRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('addIncome inserts income into database', () async {
    // Arrange
    const amount = 1500.0;

    // Act
    await repository.addIncome(
      amount: amount,
      category: IncomeCategory.salary,
      date: DateTime.now(),
      description: 'Monthly salary',
    );

    // Assert
    final incomes = await repository.watchIncomes().first;
    expect(incomes.length, equals(1));
    expect(incomes.first.amount, equals(amount));
  });
});
```

### Testing Stream Operations

```dart
test('watchIncomes returns stream that updates', () async {
  // Act - First emission (empty)
  final first = await repository.watchIncomes().first;
  expect(first.length, equals(0));

  // Act - Add income
  await repository.addIncome(
    amount: 1000,
    category: IncomeCategory.salary,
    date: DateTime.now(),
    description: 'Test',
  );

  // Assert - Second emission (has data)
  final second = await repository.watchIncomes().first;
  expect(second.length, equals(1));
});
```

### Testing Data Transformation

```dart
test('repository maps database rows to Income models', () async {
  // Act
  await repository.addIncome(
    amount: 2500.50,
    category: IncomeCategory.transaction,
    date: DateTime(2026, 4, 15),
    description: 'Freelance work',
  );

  // Assert
  final incomes = await repository.watchIncomes().first;
  final income = incomes.first;

  expect(income.amount, equals(2500.50));
  expect(income.category, equals(IncomeCategory.transaction));
  expect(income.description, equals('Freelance work'));
});
```

---

## Presentation Layer Testing

### Testing Widget Rendering

```dart
testWidgets('renders all form fields', (WidgetTester tester) async {
  // Arrange
  final mockRepository = MockIncomeRepository();

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: AddIncomePage(repository: mockRepository),
    ),
  );

  // Assert
  expect(find.text('Agregar ingreso'), findsWidgets);
  expect(find.text('Monto'), findsOneWidget);
  expect(find.text('Categoría'), findsOneWidget);
  expect(find.byType(TextFormField), findsWidgets);
});
```

### Testing Form Validation

```dart
testWidgets('shows error when amount is invalid', (tester) async {
  // Arrange
  final mockRepository = MockIncomeRepository();
  await tester.pumpWidget(MaterialApp(
    home: AddIncomePage(repository: mockRepository),
  ));

  // Act - Enter invalid amount
  await tester.enterText(find.byType(TextFormField).first, 'invalid');
  await tester.tap(find.byType(FilledButton));
  await tester.pump();

  // Assert
  expect(find.text('Ingresa un monto válido'), findsOneWidget);
});
```

### Testing Navigation

```dart
testWidgets('navigates to IncomesPage when card is tapped', (tester) async {
  // Act
  await tester.pumpWidget(const MaterialApp(home: HomePage()));
  await tester.pumpAndSettle();

  expect(find.byType(IncomesPage), findsNothing);

  // Tap Ingresos card
  await tester.tap(find.byType(Card).first);
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(IncomesPage), findsOneWidget);
});
```

### Common Widget Test Methods

```dart
// Finding widgets
find.byType(TextField)          // Find by widget type
find.text('Label')              // Find by text
find.byIcon(Icons.add)          // Find by icon
find.byWidgetPredicate(...)     // Find by custom condition

// User interactions
await tester.tap(finder)        // Tap on widget
await tester.enterText(finder, 'text')  // Type text
await tester.pump()             // Rebuild frame
await tester.pumpAndSettle()    // Pump until animations settle
await tester.pumpWidget(...)    // Load new widget

// Assertions
expect(find.byType(Widget), findsOneWidget)
expect(find.text('Label'), findsWidgets)
expect(find.byType(Widget), findsNothing)
```

---

## Common Testing Scenarios

### Scenario 1: Testing Form Submission

```dart
testWidgets('submits valid form', (tester) async {
  // Setup
  final mockRepository = MockIncomeRepository();
  await tester.pumpWidget(MaterialApp(
    home: AddIncomePage(repository: mockRepository),
  ));

  // Fill form
  await tester.enterText(
    find.byType(TextFormField).first,
    '1500',
  );

  // Select category (tapping dropdown)
  await tester.tap(find.byType(DropdownButtonFormField).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Salary'));
  await tester.pumpAndSettle();

  // Submit
  await tester.tap(find.text('Guardar ingreso'));
  await tester.pumpAndSettle();

  // Verify
  expect(mockRepository.incomesAdded, isNotEmpty);
});
```

### Scenario 2: Testing Real-time Data Updates

```dart
testWidgets('income list updates when new income added', (tester) async {
  // Setup
  final mockRepository = MockIncomeRepository();

  // Initially empty
  await tester.pumpWidget(MaterialApp(
    home: IncomesPage(repository: mockRepository),
  ));
  expect(find.text('No hay ingresos registrados'), findsOneWidget);

  // Add income (would normally be done from AddIncomePage)
  await mockRepository.addIncome(
    amount: 1000,
    category: IncomeCategory.salary,
    date: DateTime.now(),
    description: 'Test',
  );

  // Rebuild widget
  await tester.pumpWidget(MaterialApp(
    home: IncomesPage(repository: mockRepository),
  ));
  await tester.pumpAndSettle();

  // List should show income
  expect(find.text('₡1000.00'), findsOneWidget);
});
```

### Scenario 3: Testing Error Handling

```dart
testWidgets('shows snackbar on error', (tester) async {
  // Setup
  final mockRepository = MockIncomeRepository();

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error occurred')),
            );
          },
          child: const Text('Trigger Error'),
        ),
      ),
    ),
  ));

  // Trigger error
  await tester.tap(find.text('Trigger Error'));
  await tester.pumpAndSettle();

  // Verify snackbar shows
  expect(find.byType(SnackBar), findsOneWidget);
});
```

---

## Guidelines for New Features

### Checklist for Every New Feature

When adding new features, follow this checklist:

**1. Domain Layer**

- [ ] Create domain model(s) or enum
- [ ] Add unit tests for all models
- [ ] Test edge cases (empty, null, zero, large values)
- [ ] Test enum extensions/getters

**2. Data Layer (if needed)**

- [ ] Create repository class
- [ ] Add database table if using Drift
- [ ] Implement CRUD methods
- [ ] Add data tests with in-memory database
- [ ] Test stream operations
- [ ] Test data mapping

**3. Presentation Layer**

- [ ] Create UI pages/widgets
- [ ] Add mock repository for testing
- [ ] Add widget tests for rendering
- [ ] Test form validation
- [ ] Test navigation
- [ ] Test error states
- [ ] Test empty states

**4. Integration**

- [ ] Run all tests: `flutter test`
- [ ] Check test coverage
- [ ] Verify no lint warnings
- [ ] Manual testing on device

### Example: Adding Expenses Feature

```dart
// 1. Domain Tests (test/features/expenses/domain/)
test('creates Expense model', () { ... });
test('ExpenseCategory enum has labels', () { ... });

// 2. Data Tests (test/features/expenses/data/)
test('ExpenseRepository.addExpense', () { ... });
test('ExpenseRepository.watchExpenses', () { ... });

// 3. Presentation Tests (test/features/expenses/presentation/)
testWidgets('ExpensesPage renders list', (tester) { ... });
testWidgets('AddExpensePage validates amount', (tester) { ... });

// 4. Run Tests
// flutter test
```

---

## Troubleshooting

### Issue: Tests Run Slowly

**Solution:**

- Use unit tests instead of widget tests when possible
- Run specific test file instead of all tests
- Use `flutter test --start-paused` to debug

### Issue: "Package not found" in Tests

**Solution:**

```bash
flutter pub get
flutter test
```

### Issue: Tests Pass Locally but Fail in CI

**Solution:**

- Ensure all dependencies are listed in pubspec.yaml
- Use in-memory databases instead of file-based
- Avoid hardcoded paths or platform-specific code
- Use `await tester.pumpAndSettle()` to wait for animations

### Issue: StreamBuilder Tests Don't Update

**Solution:**

```dart
// Use .first to get initial stream value
final data = await stream.first;

// Or use pumpAndSettle() to wait for rebuilds
await tester.pumpAndSettle();
```

### Issue: Mocks Not Being Used

**Solution:**

- Ensure mock implements the interface correctly
- Check that you're passing mock to the widget
- Use `when().thenReturn()` for more complex mocking

---

## Running Tests in CI/CD

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --coverage
```

---

## Test Coverage Goals

| Layer        | Target | Notes                               |
| ------------ | ------ | ----------------------------------- |
| Domain       | 90%+   | Easy to test, high ROI              |
| Data         | 85%+   | In-memory DB makes testing easy     |
| Presentation | 70%+   | UI changes often, focus on behavior |
| Overall      | 75%+   | Realistic goal                      |

Check coverage with:

```bash
flutter test --coverage
```

---

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Effective Dart - Testing](https://dart.dev/guides/testing)
- [Drift Testing Guide](https://drift.simonbinder.eu/docs/transactions/#testing)
- [Widget Testing Cookbook](https://flutter.dev/docs/cookbook/testing/widget/introduction)

---

## Quick Reference

### Running Tests

```bash
flutter test                          # Run all tests
flutter test -v                       # Verbose output
flutter test --watch                  # Watch mode
flutter test test/features/incomes/   # Specific directory
flutter test --coverage               # With coverage
```

### Test File Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/path/to/file.dart';

void main() {
  group('FeatureName', () {
    test('should do something', () {
      // Arrange

      // Act

      // Assert
    });
  });
}
```

### Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/path/to/page.dart';

void main() {
  group('PageName', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      // Arrange

      // Act
      await tester.pumpWidget(const MaterialApp(home: PageName()));

      // Assert
      expect(find.byType(Widget), findsOneWidget);
    });
  });
}
```

---

**Last Updated:** April 23, 2026  
**Version:** 1.0.0  
**Project:** Mini Finance Manager
