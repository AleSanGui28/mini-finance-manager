import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/expenses/data/repository/expense_repository.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_frequency.dart';
import 'package:mini_finance_manager/features/expenses/domain/expense_type.dart';
import 'package:mini_finance_manager/features/expenses/domain/fixed_expense_category.dart';
import 'package:mini_finance_manager/features/expenses/presentation/add_expense_page.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

class FakeExpenseRepository implements ExpenseRepository {
  final addedExpenses = <Map<String, dynamic>>[];
  Expense? updatedExpense;
  final deletedIds = <String>[];

  @override
  Stream<List<Expense>> watchExpenses() {
    throw UnimplementedError();
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
  }) async {
    addedExpenses.add({
      'amount': amount,
      'currency': currency,
      'type': type,
      'paymentAccountId': paymentAccountId,
      'date': date,
      'description': description,
      'fixedCategory': fixedCategory,
      'frequency': frequency,
      'customFrequencyDescription': customFrequencyDescription,
    });
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
  group('AddExpensePage', () {
    testWidgets('renders currency selector with colones default', (
      tester,
    ) async {
      final expenseRepository = FakeExpenseRepository();
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: AddExpensePage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(DropdownButtonFormField<MoneyCurrency>),
        findsOneWidget,
      );
      expect(find.text('Moneda'), findsOneWidget);
      expect(find.text('₡ Colones'), findsOneWidget);
    });

    testWidgets('saves selected dollar currency', (tester) async {
      final expenseRepository = FakeExpenseRepository();
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: AddExpensePage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '42');

      await tester.tap(find.byType(DropdownButtonFormField<MoneyCurrency>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(r'$ Dollars').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cash - Wallet').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selecciona una fecha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(
        expenseRepository.addedExpenses.single['currency'],
        MoneyCurrency.usd,
      );
    });

    testWidgets('shows all payment account types for expenses', (tester) async {
      final expenseRepository = FakeExpenseRepository();
      final paymentAccountRepository = FakePaymentAccountRepository([
        _paymentAccount(
          id: 'bank-account',
          alias: 'Bank',
          type: PaymentAccountType.bankAccount,
        ),
        _paymentAccount(
          id: 'debit-card',
          alias: 'Debit',
          type: PaymentAccountType.debitCard,
        ),
        _paymentAccount(
          id: 'credit-card',
          alias: 'Credit',
          type: PaymentAccountType.creditCard,
        ),
        _paymentAccount(),
        _paymentAccount(
          id: 'other-account',
          alias: 'Other',
          type: PaymentAccountType.other,
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: AddExpensePage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: paymentAccountRepository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Bank - Wallet'), findsOneWidget);
      expect(find.text('Debit - Wallet'), findsOneWidget);
      expect(find.text('Credit - Wallet'), findsOneWidget);
      expect(find.text('Cash - Wallet'), findsOneWidget);
      expect(find.text('Other - Wallet'), findsOneWidget);
    });

    testWidgets('edit mode pre-fills and saves an existing expense', (
      tester,
    ) async {
      final expenseRepository = FakeExpenseRepository();
      final createdAt = DateTime(2026, 4, 28);
      final expense = Expense(
        id: 'expense-1',
        amount: 42,
        currency: MoneyCurrency.usd,
        type: ExpenseType.fixed,
        paymentAccountId: 'payment-account-1',
        date: DateTime(2026, 4, 28),
        createdAt: createdAt,
        description: 'Internet',
        fixedCategory: FixedExpenseCategory.services,
        frequency: ExpenseFrequency.custom,
        customFrequencyDescription: 'Every 45 days',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AddExpensePage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: FakePaymentAccountRepository([
              _paymentAccount(),
            ]),
            expense: expense,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar gasto'), findsWidgets);
      expect(find.text('Internet'), findsOneWidget);
      expect(find.text('Cash - Wallet'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Every 45 days'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, '50');
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(expenseRepository.updatedExpense?.id, 'expense-1');
      expect(expenseRepository.updatedExpense?.createdAt, createdAt);
      expect(expenseRepository.updatedExpense?.amount, 50);
      expect(expenseRepository.updatedExpense?.currency, MoneyCurrency.usd);
      expect(expenseRepository.updatedExpense?.type, ExpenseType.fixed);
      expect(
        expenseRepository.updatedExpense?.fixedCategory,
        FixedExpenseCategory.services,
      );
      expect(
        expenseRepository.updatedExpense?.frequency,
        ExpenseFrequency.custom,
      );
      expect(
        expenseRepository.updatedExpense?.customFrequencyDescription,
        'Every 45 days',
      );
    });

    testWidgets('edit mode clears fixed fields when type changes to sporadic', (
      tester,
    ) async {
      final expenseRepository = FakeExpenseRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: AddExpensePage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: FakePaymentAccountRepository([
              _paymentAccount(),
            ]),
            expense: _fixedExpense(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<ExpenseType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ExpenseType.sporadic.label).last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(expenseRepository.updatedExpense?.type, ExpenseType.sporadic);
      expect(expenseRepository.updatedExpense?.fixedCategory, isNull);
      expect(expenseRepository.updatedExpense?.frequency, isNull);
      expect(
        expenseRepository.updatedExpense?.customFrequencyDescription,
        isNull,
      );
    });

    testWidgets('edit mode clears custom frequency when frequency changes', (
      tester,
    ) async {
      final expenseRepository = FakeExpenseRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: AddExpensePage(
            expenseRepository: expenseRepository,
            paymentAccountRepository: FakePaymentAccountRepository([
              _paymentAccount(),
            ]),
            expense: _fixedExpense(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final frequencyDropdown = find.byType(
        DropdownButtonFormField<ExpenseFrequency>,
      );
      await tester.ensureVisible(frequencyDropdown);
      await tester.pumpAndSettle();
      await tester.tap(frequencyDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(ExpenseFrequency.monthly.label).last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(expenseRepository.updatedExpense?.type, ExpenseType.fixed);
      expect(
        expenseRepository.updatedExpense?.fixedCategory,
        FixedExpenseCategory.services,
      );
      expect(
        expenseRepository.updatedExpense?.frequency,
        ExpenseFrequency.monthly,
      );
      expect(
        expenseRepository.updatedExpense?.customFrequencyDescription,
        isNull,
      );
    });
  });
}

PaymentAccount _paymentAccount({
  String id = 'payment-account-1',
  String alias = 'Cash',
  PaymentAccountType type = PaymentAccountType.cash,
}) {
  return PaymentAccount(
    id: id,
    bankName: 'Wallet',
    alias: alias,
    type: type,
    createdAt: DateTime(2026, 4, 28),
  );
}

Expense _fixedExpense() {
  return Expense(
    id: 'expense-1',
    amount: 42,
    type: ExpenseType.fixed,
    paymentAccountId: 'payment-account-1',
    date: DateTime(2026, 4, 28),
    createdAt: DateTime(2026, 4, 28),
    description: 'Internet',
    fixedCategory: FixedExpenseCategory.services,
    frequency: ExpenseFrequency.custom,
    customFrequencyDescription: 'Every 45 days',
  );
}
