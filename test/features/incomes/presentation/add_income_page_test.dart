import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/incomes/data/repository/income_repository.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/incomes/presentation/add_income_page.dart';
// Import Income for type reference
import 'package:mini_finance_manager/features/incomes/domain/income.dart';

// Mock repository for testing
class MockIncomeRepository implements IncomeRepository {
  MockIncomeRepository() {
    incomesAdded = [];
  }

  late List<Map<String, dynamic>> incomesAdded;

  @override
  Future<void> addIncome({
    required double amount,
    required IncomeCategory category,
    required DateTime date,
    required String description,
  }) async {
    incomesAdded.add({
      'amount': amount,
      'category': category,
      'date': date,
      'description': description,
    });
  }

  @override
  Stream<List<Income>> watchIncomes() {
    // Not needed for this test
    throw UnimplementedError();
  }

  // Mock getDatabase if needed, but since it's private in IncomeRepository,
  // we're using it as an interface
}

void main() {
  group('AddIncomePage', () {
    testWidgets('renders all form fields', (WidgetTester tester) async {
      // Arrange
      final mockRepository = MockIncomeRepository();

      // Act
      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Assert
      expect(find.text('Agregar ingreso'), findsWidgets);
      expect(find.text('Nuevo ingreso'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(
        find.byType(DropdownButtonFormField<IncomeCategory>),
        findsOneWidget,
      );
      expect(find.text('Monto'), findsOneWidget);
      expect(find.text('Categoría'), findsOneWidget);
      expect(find.text('Fecha'), findsOneWidget);
      expect(find.text('Descripción opcional'), findsOneWidget);
    });

    testWidgets('shows error when amount is invalid', (
      WidgetTester tester,
    ) async {
      // Arrange
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Act - Enter invalid amount
      await tester.enterText(find.byType(TextFormField).first, 'invalid');

      // Tap save button
      await tester.tap(find.byType(FilledButton));
      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Assert
      expect(find.text('Ingresa un monto válido'), findsOneWidget);
    });

    testWidgets('shows error when amount is negative', (
      WidgetTester tester,
    ) async {
      // Arrange
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Act - Enter negative amount
      await tester.enterText(find.byType(TextFormField).first, '-100');

      // Tap save button
      await tester.tap(find.byType(FilledButton));
      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Assert
      expect(find.text('El monto debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('shows error when amount is zero', (WidgetTester tester) async {
      // Arrange
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Act - Enter zero amount
      await tester.enterText(find.byType(TextFormField).first, '0');

      // Tap save button
      await tester.tap(find.byType(FilledButton));
      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Assert
      expect(find.text('El monto debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('renders save button', (WidgetTester tester) async {
      // Arrange
      final mockRepository = MockIncomeRepository();

      // Act
      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Assert
      expect(find.text('Guardar ingreso'), findsOneWidget);
      expect(find.byIcon(Icons.save_outlined), findsOneWidget);
    });

    testWidgets('renders app bar with title', (WidgetTester tester) async {
      // Arrange
      final mockRepository = MockIncomeRepository();

      // Act
      await tester.pumpWidget(
        MaterialApp(home: AddIncomePage(repository: mockRepository)),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Agregar ingreso'), findsWidgets);
    });
  });
}
