import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/expenses/data/repository/expense_repository.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_frequency.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_type.dart';
import 'package:mini_finance_manager/features/expenses/domain/fixed_expense_category.dart';
import 'package:mini_finance_manager/features/expenses/presentation/expenses_page.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository(this.expenses);

  final List<Expense> expenses;
  final deletedIds = <String>[];
  Expense? updatedExpense;

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);

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
  Future<void> updateExpense(Expense expense) async {
    updatedExpense = expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    deletedIds.add(id);
  }
}

class FakePaymentAccountRepository implements PaymentAccountRepository {
  FakePaymentAccountRepository(this.accounts);

  final List<PaymentAccount> accounts;

  @override
  Stream<List<PaymentAccount>> watchPaymentAccounts() => Stream.value(accounts);

  @override
  Future<void> addPaymentAccount({
    required String bankName,
    required String alias,
    required PaymentAccountType type,
    String? cardLastDigits,
    String? iban,
    int? closingDayOfMonth,
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

void main() {
  group('ExpensesPage', () {
    testWidgets('renders each expense with its own currency symbol', (
      tester,
    ) async {
      final expenseRepository = FakeExpenseRepository([
        _expense(currency: MoneyCurrency.usd),
      ]);
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesPage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$42.00'), findsWidgets);
    });

    testWidgets('groups summary totals by currency', (tester) async {
      final expenseRepository = FakeExpenseRepository([
        _expense(id: 'expense-1', amount: 100),
        _expense(id: 'expense-2', amount: 40),
        _expense(id: 'expense-3', amount: 25, currency: MoneyCurrency.usd),
        _expense(id: 'expense-4', amount: 5, currency: MoneyCurrency.usd),
      ]);
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesPage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('140.00'), findsOneWidget);
      expect(find.text(r'$30.00'), findsOneWidget);
    });

    testWidgets('opens expense detail when tapping an expense', (tester) async {
      final expenseRepository = FakeExpenseRepository([
        _expense(description: 'Lunch'),
      ]);
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesPage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle del gasto'), findsOneWidget);
      expect(find.textContaining('42.00'), findsWidgets);
      expect(find.text('Cash'), findsWidgets);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });

    testWidgets('opens expense detail when long pressing an expense', (
      tester,
    ) async {
      final expenseRepository = FakeExpenseRepository([
        _expense(description: 'Lunch'),
      ]);
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesPage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Lunch'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle del gasto'), findsOneWidget);
    });

    testWidgets('deletes expense from detail page after tapping an expense', (
      tester,
    ) async {
      final expenseRepository = FakeExpenseRepository([
        _expense(id: 'expense-1', description: 'Lunch'),
      ]);
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesPage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();

      final deleteButton = find.widgetWithText(OutlinedButton, 'Eliminar');
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(expenseRepository.deletedIds, ['expense-1']);
      expect(find.text('Gasto eliminado'), findsOneWidget);
    });

    testWidgets('opens expense editor when swiping right', (tester) async {
      final expenseRepository = FakeExpenseRepository([
        _expense(description: 'Lunch'),
      ]);
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesPage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _swipeRight(tester);
      await tester.pumpAndSettle();

      expect(find.text('Editar gasto'), findsWidgets);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Cash - Wallet'), findsOneWidget);
    });

    testWidgets(
      'does not delete expense when swipe confirmation is cancelled',
      (tester) async {
        final expenseRepository = FakeExpenseRepository([
          _expense(id: 'expense-1', description: 'Lunch'),
        ]);
        final paymentAccountRepository = FakePaymentAccountRepository([
          _paymentAccount(),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: ExpensesPage(
              expenseRepository: expenseRepository,
              paymentAccountRepository: paymentAccountRepository,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await _swipeLeft(tester);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(expenseRepository.deletedIds, isEmpty);
        expect(find.text('Lunch'), findsOneWidget);
      },
    );

    testWidgets('deletes expense when swipe confirmation is accepted', (
      tester,
    ) async {
      final expenseRepository = FakeExpenseRepository([
        _expense(id: 'expense-1', description: 'Lunch'),
      ]);
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExpensesPage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _swipeLeft(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(expenseRepository.deletedIds, ['expense-1']);
      expect(find.text('Gasto eliminado'), findsOneWidget);
    });
  });
}

Expense _expense({
  String id = 'expense-1',
  double amount = 42,
  MoneyCurrency currency = MoneyCurrency.crc,
  ExpenseType type = ExpenseType.sporadic,
  String description = 'Lunch',
  FixedExpenseCategory? fixedCategory,
  ExpenseFrequency? frequency,
}) {
  return Expense(
    id: id,
    amount: amount,
    currency: currency,
    type: type,
    paymentAccountId: 'payment-account-1',
    date: DateTime(2026, 4, 28),
    createdAt: DateTime(2026, 4, 28),
    description: description,
    fixedCategory: fixedCategory,
    frequency: frequency,
  );
}

PaymentAccount _paymentAccount() {
  return PaymentAccount(
    id: 'payment-account-1',
    bankName: 'Wallet',
    alias: 'Cash',
    type: PaymentAccountType.cash,
    createdAt: DateTime(2026, 4, 28),
  );
}

Future<void> _swipeRight(WidgetTester tester) async {
  await _dragExpense(tester, const Offset(120, 0));
}

Future<void> _swipeLeft(WidgetTester tester) async {
  await _dragExpense(tester, const Offset(-120, 0));
}

Future<void> _dragExpense(WidgetTester tester, Offset offset) async {
  final row = find.byWidgetPredicate(
    (widget) =>
        widget is GestureDetector && widget.onHorizontalDragUpdate != null,
  );
  await tester.drag(row.first, offset);
  await tester.pumpAndSettle();
}
