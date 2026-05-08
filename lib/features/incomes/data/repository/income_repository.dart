import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../personal/domain/payment_account_type.dart';
import '../../domain/income.dart';
import '../../domain/income_category.dart';
import '../../../shared/domain/money_currency.dart';

class IncomeRepository {
  final AppDatabase _database;

  IncomeRepository(this._database);

  Stream<List<Income>> watchIncomes() {
    return _database.select(_database.incomesTable).watch().map((rows) {
      return rows.map(_mapRowToIncome).toList();
    });
  }

  Future<void> addIncome({
    required double amount,
    MoneyCurrency currency = MoneyCurrency.crc,
    required String paymentAccountId,
    required IncomeCategory category,
    required DateTime date,
    required String description,
  }) async {
    await _validatePaymentAccountCanReceiveIncome(paymentAccountId);

    final incomeRow = IncomesTableCompanion(
      id: drift.Value(const Uuid().v4()),
      amount: drift.Value(amount),
      currency: drift.Value(currency.name),
      paymentAccountId: drift.Value(paymentAccountId),
      category: drift.Value(category.name),
      date: drift.Value(date),
      description: drift.Value(description),
      createdAt: drift.Value(DateTime.now()),
    );

    await _database.into(_database.incomesTable).insert(incomeRow);
  }

  Future<void> updateIncome(Income income) async {
    final paymentAccountId = income.paymentAccountId;
    if (paymentAccountId == null) {
      throw ArgumentError('Income must have a payment account');
    }

    await _validatePaymentAccountCanReceiveIncome(paymentAccountId);

    final incomeRow = IncomesTableCompanion(
      id: drift.Value(income.id),
      amount: drift.Value(income.amount),
      currency: drift.Value(income.currency.name),
      paymentAccountId: drift.Value(paymentAccountId),
      category: drift.Value(income.category.name),
      date: drift.Value(income.date),
      description: drift.Value(income.description),
      createdAt: drift.Value(income.createdAt),
    );

    await _database.update(_database.incomesTable).replace(incomeRow);
  }

  Future<void> deleteIncome(String id) {
    return (_database.delete(
      _database.incomesTable,
    )..where((table) => table.id.equals(id))).go();
  }

  Income _mapRowToIncome(IncomesTableData row) {
    return Income(
      id: row.id,
      amount: row.amount,
      currency: _mapCurrency(row.currency),
      paymentAccountId: row.paymentAccountId,
      category: IncomeCategory.values.firstWhere((e) => e.name == row.category),
      date: row.date,
      createdAt: row.createdAt,
      description: row.description,
    );
  }

  MoneyCurrency _mapCurrency(String value) {
    return MoneyCurrency.values.firstWhere(
      (currency) => currency.name == value,
      orElse: () => MoneyCurrency.crc,
    );
  }

  Future<void> _validatePaymentAccountCanReceiveIncome(
    String paymentAccountId,
  ) async {
    final query = _database.select(_database.paymentAccountsTable)
      ..where((table) => table.id.equals(paymentAccountId));
    final account = await query.getSingleOrNull();

    if (account == null) {
      throw ArgumentError('Payment account not found');
    }

    final type = _mapPaymentAccountType(account.type);
    if (!type.canReceiveIncome) {
      throw ArgumentError('Payment account cannot receive income');
    }
  }

  PaymentAccountType _mapPaymentAccountType(String value) {
    return PaymentAccountType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => PaymentAccountType.other,
    );
  }
}
