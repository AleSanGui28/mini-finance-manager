import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/home/presentation/home_page.dart';
import 'package:mini_finance_manager/features/expenses/data/repository/expense_repository.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense.dart'
    as expense_domain;
import 'package:mini_finance_manager/features/expenses/domain/expense_frequency.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_type.dart';
import 'package:mini_finance_manager/features/expenses/domain/fixed_expense_category.dart';
import 'package:mini_finance_manager/features/incomes/data/repository/income_repository.dart';
import 'package:mini_finance_manager/features/incomes/domain/income.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/incomes/presentation/incomes_page.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';

// Mock repository for testing
class MockIncomeRepository implements IncomeRepository {
  final List<Income> _incomes;

  MockIncomeRepository([List<Income>? incomes]) : _incomes = incomes ?? [];

  @override
  Stream<List<Income>> watchIncomes() {
    return Stream.value(_incomes);
  }

  @override
  Future<void> addIncome({
    required double amount,
    required IncomeCategory category,
    required DateTime date,
    required String description,
  }) {
    // Not needed for these tests
    throw UnimplementedError();
  }
}

class MockPaymentAccountRepository implements PaymentAccountRepository {
  final List<PaymentAccount> _accounts;

  MockPaymentAccountRepository([List<PaymentAccount>? accounts])
    : _accounts = accounts ?? [];

  @override
  Stream<List<PaymentAccount>> watchPaymentAccounts() {
    return Stream.value(_accounts);
  }

  @override
  Future<void> addPaymentAccount({
    required String bankName,
    required String alias,
    required PaymentAccountType type,
    String? cardLastDigits,
    String? iban,
  }) {
    throw UnimplementedError();
  }
}

class MockExpenseRepository implements ExpenseRepository {
  final List<expense_domain.Expense> _expenses;

  MockExpenseRepository([List<expense_domain.Expense>? expenses])
    : _expenses = expenses ?? [];

  @override
  Stream<List<expense_domain.Expense>> watchExpenses() {
    return Stream.value(_expenses);
  }

  @override
  Future<void> addExpense({
    required double amount,
    required ExpenseType type,
    required String paymentAccountId,
    required DateTime date,
    String? description,
    FixedExpenseCategory? fixedCategory,
    ExpenseFrequency? frequency,
    String? customFrequencyDescription,
  }) {
    throw UnimplementedError();
  }
}

Widget buildHomePage() {
  return MaterialApp(
    home: HomePage(
      incomeRepository: MockIncomeRepository(),
      paymentAccountRepository: MockPaymentAccountRepository(),
      expenseRepository: MockExpenseRepository(),
    ),
  );
}

void main() {
  group('HomePage', () {
    testWidgets('renders app bar with title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildHomePage());

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Mini Finance Manager'), findsOneWidget);
    });

    testWidgets('renders Ingresos card module', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildHomePage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ingresos'), findsWidgets);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('Ingresos card shows total amount', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildHomePage());
      await tester.pumpAndSettle();

      // Assert - Initially should show ₡0.00 or the current total
      expect(find.byType(Text), findsWidgets);
      // Check for currency symbol (₡) in the widget tree
      final text = find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data != null && widget.data!.contains('₡'),
      );
      expect(text, findsWidgets);
    });

    testWidgets('Ingresos card is tappable', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildHomePage());
      await tester.pumpAndSettle();

      // Find and tap the Ingresos card (GestureDetector)
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Assert - Should navigate to IncomesPage
      expect(find.byType(IncomesPage), findsOneWidget);
    });

    testWidgets('navigates to IncomesPage when Ingresos card is tapped', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildHomePage());
      await tester.pumpAndSettle();

      // Get initial route
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(IncomesPage), findsNothing);

      // Tap Ingresos card
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Assert - Should now show IncomesPage
      expect(find.byType(IncomesPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('renders income count on card', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildHomePage());
      await tester.pumpAndSettle();

      // Assert - Should show income count (initially 0)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              (widget.data!.contains('ingreso') ||
                  widget.data!.contains('ingresos')),
        ),
        findsWidgets,
      );
    });

    testWidgets('renders HomePage without errors', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildHomePage());

      // Assert
      expect(find.byType(HomePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Ingresos card contains trending up icon', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildHomePage());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });
  });
}
