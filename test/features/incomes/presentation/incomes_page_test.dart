import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/incomes/data/repository/income_repository.dart';
import 'package:mini_finance_manager/features/incomes/domain/income.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/incomes/presentation/incomes_page.dart';
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
  group('IncomesPage', () {
    testWidgets('opens income detail from the visible income list', (
      tester,
    ) async {
      final repository = FakeIncomeRepository([
        _income(currency: MoneyCurrency.usd, description: 'Monthly salary'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly salary'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle del ingreso'), findsOneWidget);
      expect(find.text(r'$1200.00'), findsWidgets);
      expect(find.text('Cash'), findsWidgets);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });

    testWidgets('renders each income with its own currency symbol', (
      tester,
    ) async {
      final repository = FakeIncomeRepository([
        _income(currency: MoneyCurrency.usd, description: 'Dollar salary'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      expect(find.text(r'$1200.00'), findsWidgets);
    });

    testWidgets('shows associated payment account alias in the list', (
      tester,
    ) async {
      final repository = FakeIncomeRepository([
        _income(description: 'Monthly salary'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      expect(find.text('Salary - Cash'), findsOneWidget);
    });

    testWidgets('groups summary totals by currency', (tester) async {
      final repository = FakeIncomeRepository([
        _income(id: 'income-1', amount: 100, description: 'Salary'),
        _income(id: 'income-2', amount: 40, description: 'Bonus'),
        _income(
          id: 'income-3',
          amount: 25,
          currency: MoneyCurrency.usd,
          description: 'Dollar income',
        ),
        _income(
          id: 'income-4',
          amount: 5,
          currency: MoneyCurrency.usd,
          description: 'Dollar bonus',
        ),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      expect(find.textContaining('140.00'), findsOneWidget);
      expect(find.text(r'$30.00'), findsOneWidget);
    });

    testWidgets('opens edit form from income detail', (tester) async {
      final repository = FakeIncomeRepository([
        _income(description: 'Monthly salary'),
      ]);

      await tester.pumpWidget(_buildPage(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly salary'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('Editar ingreso'), findsWidgets);
      expect(find.text('Monthly salary'), findsOneWidget);
      expect(find.text('Cash - Wallet'), findsOneWidget);
    });

    testWidgets(
      'deletes income from the visible income list after confirmation',
      (tester) async {
        final repository = FakeIncomeRepository([
          _income(id: 'salary-income', description: 'Monthly salary'),
        ]);

        await tester.pumpWidget(_buildPage(repository));
        await tester.pumpAndSettle();

        await _swipeLeft(tester);
        await tester.tap(find.text('Eliminar'));
        await tester.pump();

        expect(repository.deletedIds, ['salary-income']);
      },
    );
  });
}

Widget _buildPage(FakeIncomeRepository repository) {
  return MaterialApp(
    home: IncomesPage(
      repository: repository,
      paymentAccountRepository: FakePaymentAccountRepository([
        _paymentAccount(),
      ]),
    ),
  );
}

Income _income({
  String id = 'income-id',
  double amount = 1200,
  String description = '',
  MoneyCurrency currency = MoneyCurrency.crc,
  DateTime? date,
}) {
  return Income(
    id: id,
    amount: amount,
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
