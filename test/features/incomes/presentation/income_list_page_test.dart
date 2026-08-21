import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/incomes/data/repository/income_repository.dart';
import 'package:mini_finance_manager/features/incomes/domain/income.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/incomes/presentation/income_list_page.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

class FakeIncomeRepository implements IncomeRepository {
  FakeIncomeRepository(this.incomes);

  final List<Income> incomes;
  final deletedIds = <String>[];

  @override
  Stream<List<Income>> watchIncomes() => Stream.value(incomes);

  @override
  Future<void> addIncome({
    required double amount,
    MoneyCurrency currency = MoneyCurrency.crc,
    required String paymentAccountId,
    required IncomeCategory category,
    required DateTime date,
    required String description,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateIncome(Income income) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteIncome(String id) async {
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
  group('IncomeListPage', () {
    testWidgets('opens income detail when tapping an income', (tester) async {
      final repository = FakeIncomeRepository([
        _income(currency: MoneyCurrency.usd, description: 'Monthly salary'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly salary'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle del ingreso'), findsOneWidget);
      expect(find.text(r'$1200.00'), findsOneWidget);
      expect(find.text('Cash'), findsWidgets);
    });

    testWidgets('renders each income with its own currency symbol', (
      tester,
    ) async {
      final repository = FakeIncomeRepository([
        _income(currency: MoneyCurrency.usd, description: 'Dollar salary'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      expect(find.text(r'$1200.00'), findsOneWidget);
    });

    testWidgets('shows associated payment account alias in the list', (
      tester,
    ) async {
      final repository = FakeIncomeRepository([
        _income(description: 'Freelance payment'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      expect(find.text('Salary - Cash'), findsOneWidget);
    });

    testWidgets('opens income detail when long pressing an income', (
      tester,
    ) async {
      final repository = FakeIncomeRepository([
        _income(description: 'Freelance payment'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Freelance payment'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle del ingreso'), findsOneWidget);
    });

    testWidgets('does not delete income when swipe confirmation is cancelled', (
      tester,
    ) async {
      final repository = FakeIncomeRepository([
        _income(id: 'salary-income', description: 'Monthly salary'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _swipeLeft(tester);

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(repository.deletedIds, isEmpty);
      expect(find.text('Monthly salary'), findsOneWidget);
    });

    testWidgets('deletes income when swipe confirmation is accepted', (
      tester,
    ) async {
      final repository = FakeIncomeRepository([
        _income(id: 'salary-income', description: 'Monthly salary'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await _swipeLeft(tester);
      await tester.tap(find.text('Eliminar'));
      await tester.pump();

      expect(repository.deletedIds, ['salary-income']);
    });
  });
}

Widget _buildPage(FakeIncomeRepository repository) {
  return MaterialApp(
    home: IncomeListPage(
      repository: repository,
      paymentAccountRepository: FakePaymentAccountRepository([
        _paymentAccount(),
      ]),
    ),
  );
}

Income _income({
  String id = 'income-id',
  String description = '',
  MoneyCurrency currency = MoneyCurrency.crc,
  DateTime? date,
}) {
  return Income(
    id: id,
    amount: 1200,
    currency: currency,
    paymentAccountId: 'payment-account-1',
    category: IncomeCategory.salary,
    date: date ?? DateTime(2026, 4, 26),
    createdAt: DateTime(2026, 4, 26),
    description: description,
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

Future<void> _swipeLeft(WidgetTester tester) async {
  final row = find.byWidgetPredicate(
    (widget) =>
        widget is GestureDetector && widget.onHorizontalDragUpdate != null,
  );
  await tester.drag(row.first, const Offset(-120, 0));
  await tester.pumpAndSettle();
}
