import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/incomes/data/repository/income_repository.dart';
import 'package:mini_finance_manager/features/incomes/domain/income.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';
import 'package:mini_finance_manager/features/incomes/presentation/add_income_page.dart';
import 'package:mini_finance_manager/features/personal/data/repository/payment_account_repository.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account.dart';
import 'package:mini_finance_manager/features/personal/domain/payment_account_type.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

class MockIncomeRepository implements IncomeRepository {
  final incomesAdded = <Map<String, dynamic>>[];
  Income? updatedIncome;

  @override
  Future<void> addIncome({
    required double amount,
    MoneyCurrency currency = MoneyCurrency.crc,
    required String paymentAccountId,
    required IncomeCategory category,
    required DateTime date,
    required String description,
  }) async {
    incomesAdded.add({
      'amount': amount,
      'currency': currency,
      'paymentAccountId': paymentAccountId,
      'category': category,
      'date': date,
      'description': description,
    });
  }

  @override
  Stream<List<Income>> watchIncomes() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateIncome(Income income) async {
    updatedIncome = income;
  }

  @override
  Future<void> deleteIncome(String id) {
    throw UnimplementedError();
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
  group('AddIncomePage', () {
    testWidgets('renders all form fields', (WidgetTester tester) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(_buildPage(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Agregar ingreso'), findsWidgets);
      expect(find.text('Nuevo ingreso'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(
        find.byType(DropdownButtonFormField<IncomeCategory>),
        findsOneWidget,
      );
      expect(
        find.byType(DropdownButtonFormField<MoneyCurrency>),
        findsOneWidget,
      );
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Monto'), findsOneWidget);
      expect(find.text('Moneda'), findsOneWidget);
      expect(find.textContaining('Colones'), findsOneWidget);
      expect(find.text('Cuenta de pago'), findsOneWidget);
      expect(find.textContaining('Categor'), findsOneWidget);
      expect(find.text('Fecha'), findsOneWidget);
      expect(find.textContaining('Descripci'), findsOneWidget);
    });

    testWidgets('only shows income-eligible payment accounts', (tester) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(
        _buildPage(
          mockRepository,
          accounts: [
            _paymentAccount(),
            _paymentAccount(
              id: 'credit-account',
              alias: 'Credit',
              type: PaymentAccountType.creditCard,
            ),
            _paymentAccount(
              id: 'other-account',
              alias: 'Other',
              type: PaymentAccountType.other,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Cash - Wallet'), findsOneWidget);
      expect(find.text('Credit - Wallet'), findsNothing);
      expect(find.text('Other - Wallet'), findsNothing);
    });

    testWidgets('shows a helpful message when no eligible accounts exist', (
      tester,
    ) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(
        _buildPage(
          mockRepository,
          accounts: [
            _paymentAccount(
              id: 'credit-account',
              alias: 'Credit',
              type: PaymentAccountType.creditCard,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Agrega una cuenta bancaria, tarjeta de debito o efectivo para registrar ingresos.',
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isFalse,
      );
    });

    testWidgets('saves selected account and dollar currency for new income', (
      WidgetTester tester,
    ) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(_buildPage(mockRepository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '125');

      await tester.tap(find.byType(DropdownButtonFormField<MoneyCurrency>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(r'$ Dollars').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cash - Wallet').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<IncomeCategory>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(IncomeCategory.salary.label).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selecciona una fecha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await _tapSave(tester);
      await tester.pumpAndSettle();

      expect(mockRepository.incomesAdded.single['currency'], MoneyCurrency.usd);
      expect(
        mockRepository.incomesAdded.single['paymentAccountId'],
        'payment-account-1',
      );
    });

    testWidgets(
      'edit mode preselects and saves existing currency and account',
      (WidgetTester tester) async {
        final mockRepository = MockIncomeRepository();
        final income = Income(
          id: 'income-1',
          amount: 125,
          currency: MoneyCurrency.usd,
          paymentAccountId: 'payment-account-1',
          category: IncomeCategory.salary,
          date: DateTime(2026, 4, 27),
          createdAt: DateTime(2026, 4, 27),
          description: 'Monthly salary',
        );

        await tester.pumpWidget(_buildPage(mockRepository, income: income));
        await tester.pumpAndSettle();

        expect(find.text(r'$ Dollars'), findsOneWidget);
        expect(find.text('Cash - Wallet'), findsOneWidget);

        await _tapSave(tester);
        await tester.pumpAndSettle();

        expect(mockRepository.updatedIncome?.currency, MoneyCurrency.usd);
        expect(
          mockRepository.updatedIncome?.paymentAccountId,
          'payment-account-1',
        );
      },
    );

    testWidgets('shows error when amount is invalid', (
      WidgetTester tester,
    ) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(_buildPage(mockRepository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'invalid');

      await _tapSave(tester);

      expect(find.textContaining('Ingresa un monto'), findsOneWidget);
    });

    testWidgets('shows error when amount is negative', (
      WidgetTester tester,
    ) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(_buildPage(mockRepository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '-100');

      await _tapSave(tester);

      expect(find.text('El monto debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('shows error when amount is zero', (WidgetTester tester) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(_buildPage(mockRepository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '0');

      await _tapSave(tester);

      expect(find.text('El monto debe ser mayor a 0'), findsOneWidget);
    });

    testWidgets('renders save button', (WidgetTester tester) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(_buildPage(mockRepository));
      await tester.pumpAndSettle();

      expect(find.text('Guardar ingreso'), findsOneWidget);
      expect(find.byIcon(Icons.save_outlined), findsOneWidget);
    });

    testWidgets('renders app bar with title', (WidgetTester tester) async {
      final mockRepository = MockIncomeRepository();

      await tester.pumpWidget(_buildPage(mockRepository));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Agregar ingreso'), findsWidgets);
    });
  });
}

Widget _buildPage(
  MockIncomeRepository incomeRepository, {
  List<PaymentAccount>? accounts,
  Income? income,
}) {
  return MaterialApp(
    home: AddIncomePage(
      repository: incomeRepository,
      paymentAccountRepository: FakePaymentAccountRepository(
        accounts ?? [_paymentAccount()],
      ),
      income: income,
    ),
  );
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

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(FilledButton));
  await tester.tap(find.byType(FilledButton));
  await tester.pump();
}
