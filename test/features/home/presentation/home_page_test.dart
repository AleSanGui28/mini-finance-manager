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
import 'package:mini_finance_manager/features/personal/data/repository/saving_goal_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal_status.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

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
    MoneyCurrency currency = MoneyCurrency.crc,
    required String paymentAccountId,
    required IncomeCategory category,
    required DateTime date,
    required String description,
  }) {
    // Not needed for these tests
    throw UnimplementedError();
  }

  @override
  Future<void> updateIncome(Income income) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteIncome(String id) {
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

  @override
  Future<void> updatePaymentAccount(PaymentAccount paymentAccount) {
    throw UnimplementedError();
  }

  @override
  Future<PaymentAccountLinkedRecordCounts> getLinkedRecordCounts(
    String paymentAccountId,
  ) async {
    return const PaymentAccountLinkedRecordCounts(
      incomeCount: 0,
      expenseCount: 0,
    );
  }

  @override
  Future<bool> canDeletePaymentAccount(String paymentAccountId) async => true;

  @override
  Future<bool> hasLinkedRecords(String paymentAccountId) async => false;

  @override
  Future<void> deletePaymentAccount(String paymentAccountId) {
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
    MoneyCurrency currency = MoneyCurrency.crc,
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

  @override
  Future<void> updateExpense(expense_domain.Expense expense) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExpense(String id) {
    throw UnimplementedError();
  }
}

class MockSavingGoalRepository implements SavingGoalRepository {
  final List<SavingGoal> _savingGoals;

  MockSavingGoalRepository([List<SavingGoal>? savingGoals])
    : _savingGoals = savingGoals ?? [];

  @override
  Stream<List<SavingGoal>> watchSavingGoals() {
    return Stream.value(_savingGoals);
  }

  @override
  Future<void> addSavingGoal({
    required String title,
    required double targetAmount,
    DateTime? targetDate,
    SavingGoalStatus status = SavingGoalStatus.active,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateSavingGoal(SavingGoal savingGoal) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSavingGoal(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> freezeSavingGoal(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> resumeSavingGoal(String id) {
    throw UnimplementedError();
  }
}

Widget buildHomePage({
  IncomeRepository? incomeRepository,
  PaymentAccountRepository? paymentAccountRepository,
  ExpenseRepository? expenseRepository,
  SavingGoalRepository? savingGoalRepository,
}) {
  return MaterialApp(
    home: HomePage(
      incomeRepository: incomeRepository ?? MockIncomeRepository(),
      paymentAccountRepository:
          paymentAccountRepository ?? MockPaymentAccountRepository(),
      expenseRepository: expenseRepository ?? MockExpenseRepository(),
      savingGoalRepository: savingGoalRepository ?? MockSavingGoalRepository(),
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

    testWidgets('Ingresos card groups totals by currency', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildHomePage(
          incomeRepository: MockIncomeRepository([
            _income(id: 'income-1', amount: 100),
            _income(id: 'income-2', amount: 40),
            _income(id: 'income-3', amount: 25, currency: MoneyCurrency.usd),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₡140.00'), findsOneWidget);
      expect(find.text(r'$25.00'), findsOneWidget);
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

    testWidgets('Personal card shows payment accounts and savings summary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildHomePage(
          paymentAccountRepository: MockPaymentAccountRepository([
            _paymentAccount(id: 'payment-account-1'),
            _paymentAccount(id: 'payment-account-2'),
          ]),
          savingGoalRepository: MockSavingGoalRepository([
            _savingGoal(id: 'saving-goal-1', targetAmount: 1000),
            _savingGoal(id: 'saving-goal-2', targetAmount: 500),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Cuentas de pago'), findsOneWidget);
      expect(find.text('Ahorros'), findsOneWidget);
      expect(find.text('Meta de ahorro: 1500.00'), findsOneWidget);
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

    testWidgets('Gastos card groups totals by currency', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildHomePage(
          expenseRepository: MockExpenseRepository([
            _expense(id: 'expense-1', amount: 100),
            _expense(id: 'expense-2', amount: 40),
            _expense(id: 'expense-3', amount: 25, currency: MoneyCurrency.usd),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₡140.00'), findsOneWidget);
      expect(find.text(r'$25.00'), findsOneWidget);
    });
  });
}

Income _income({
  required String id,
  required double amount,
  MoneyCurrency currency = MoneyCurrency.crc,
}) {
  return Income(
    id: id,
    amount: amount,
    currency: currency,
    paymentAccountId: 'payment-account-1',
    category: IncomeCategory.salary,
    date: DateTime(2026, 4, 28),
    createdAt: DateTime(2026, 4, 28),
    description: '',
  );
}

expense_domain.Expense _expense({
  required String id,
  required double amount,
  MoneyCurrency currency = MoneyCurrency.crc,
}) {
  return expense_domain.Expense(
    id: id,
    amount: amount,
    currency: currency,
    type: ExpenseType.sporadic,
    paymentAccountId: 'payment-account-1',
    date: DateTime(2026, 4, 28),
    createdAt: DateTime(2026, 4, 28),
  );
}

PaymentAccount _paymentAccount({required String id}) {
  return PaymentAccount(
    id: id,
    bankName: 'Banco Nacional',
    alias: 'Principal',
    type: PaymentAccountType.cash,
    createdAt: DateTime(2026, 4, 28),
  );
}

SavingGoal _savingGoal({required String id, required double targetAmount}) {
  return SavingGoal(
    id: id,
    title: 'Ahorro',
    targetAmount: targetAmount,
    status: SavingGoalStatus.active,
    createdAt: DateTime(2026, 4, 28),
  );
}
