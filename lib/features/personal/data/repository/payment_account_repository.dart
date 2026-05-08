import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/payment_account.dart';
import '../../domain/payment_account_type.dart';

class PaymentAccountRepository {
  final AppDatabase _database;

  PaymentAccountRepository(this._database);

  Stream<List<PaymentAccount>> watchPaymentAccounts() {
    return _database.select(_database.paymentAccountsTable).watch().map((rows) {
      return rows.map(_mapRowToPaymentAccount).toList();
    });
  }

  Future<void> addPaymentAccount({
    required String bankName,
    required String alias,
    required PaymentAccountType type,
    String? cardLastDigits,
    String? iban,
  }) {
    final paymentAccountRow = PaymentAccountsTableCompanion(
      id: drift.Value(const Uuid().v4()),
      bankName: drift.Value(bankName),
      alias: drift.Value(alias),
      type: drift.Value(type.name),
      cardLastDigits: cardLastDigits != null
          ? drift.Value(cardLastDigits)
          : const drift.Value.absent(),
      iban: iban != null ? drift.Value(iban) : const drift.Value.absent(),
      createdAt: drift.Value(DateTime.now()),
    );

    return _database
        .into(_database.paymentAccountsTable)
        .insert(paymentAccountRow);
  }

  Future<void> updatePaymentAccount(PaymentAccount paymentAccount) async {
    await _validateAccountTypeChange(paymentAccount);

    final paymentAccountRow = PaymentAccountsTableCompanion(
      id: drift.Value(paymentAccount.id),
      bankName: drift.Value(paymentAccount.bankName),
      alias: drift.Value(paymentAccount.alias),
      type: drift.Value(paymentAccount.type.name),
      cardLastDigits: drift.Value<String?>(paymentAccount.cardLastDigits),
      iban: drift.Value<String?>(paymentAccount.iban),
      createdAt: drift.Value(paymentAccount.createdAt),
    );

    await _database
        .update(_database.paymentAccountsTable)
        .replace(paymentAccountRow);
  }

  Future<PaymentAccountLinkedRecordCounts> getLinkedRecordCounts(
    String paymentAccountId,
  ) async {
    final incomeQuery = _database.select(_database.incomesTable)
      ..where((table) => table.paymentAccountId.equals(paymentAccountId));
    final expenseQuery = _database.select(_database.expensesTable)
      ..where((table) => table.paymentAccountId.equals(paymentAccountId));

    final incomes = await incomeQuery.get();
    final expenses = await expenseQuery.get();

    return PaymentAccountLinkedRecordCounts(
      incomeCount: incomes.length,
      expenseCount: expenses.length,
    );
  }

  Future<bool> canDeletePaymentAccount(String paymentAccountId) async {
    final counts = await getLinkedRecordCounts(paymentAccountId);
    return !counts.hasLinkedRecords;
  }

  Future<bool> hasLinkedRecords(String paymentAccountId) async {
    final counts = await getLinkedRecordCounts(paymentAccountId);
    return counts.hasLinkedRecords;
  }

  Future<void> deletePaymentAccount(String paymentAccountId) async {
    final counts = await getLinkedRecordCounts(paymentAccountId);

    if (counts.hasLinkedRecords) {
      throw PaymentAccountDeleteBlockedException(counts);
    }

    await (_database.delete(
      _database.paymentAccountsTable,
    )..where((table) => table.id.equals(paymentAccountId))).go();
  }

  PaymentAccount _mapRowToPaymentAccount(PaymentAccountsTableData row) {
    PaymentAccountType type = PaymentAccountType.other;
    try {
      type = PaymentAccountType.values.firstWhere((e) => e.name == row.type);
    } catch (e) {
      type = PaymentAccountType.other;
    }

    return PaymentAccount(
      id: row.id,
      bankName: row.bankName,
      alias: row.alias,
      type: type,
      cardLastDigits: row.cardLastDigits,
      iban: row.iban,
      createdAt: row.createdAt,
    );
  }

  Future<void> _validateAccountTypeChange(PaymentAccount paymentAccount) async {
    if (paymentAccount.type.canReceiveIncome) {
      return;
    }

    final counts = await getLinkedRecordCounts(paymentAccount.id);
    if (counts.incomeCount > 0) {
      throw PaymentAccountTypeChangeBlockedException(counts);
    }
  }
}

class PaymentAccountLinkedRecordCounts {
  const PaymentAccountLinkedRecordCounts({
    required this.incomeCount,
    required this.expenseCount,
  });

  final int incomeCount;
  final int expenseCount;

  bool get hasLinkedRecords => incomeCount > 0 || expenseCount > 0;
}

class PaymentAccountDeleteBlockedException implements Exception {
  const PaymentAccountDeleteBlockedException(this.counts);

  final PaymentAccountLinkedRecordCounts counts;

  String get message {
    final parts = <String>[];
    if (counts.incomeCount > 0) {
      parts.add(_recordLabel(counts.incomeCount, 'ingreso', 'ingresos'));
    }
    if (counts.expenseCount > 0) {
      parts.add(_recordLabel(counts.expenseCount, 'gasto', 'gastos'));
    }

    return 'No se puede eliminar esta cuenta porque tiene registros '
        'vinculados: ${parts.join(' y ')}.';
  }

  @override
  String toString() => message;
}

class PaymentAccountTypeChangeBlockedException implements Exception {
  const PaymentAccountTypeChangeBlockedException(this.counts);

  final PaymentAccountLinkedRecordCounts counts;

  String get message {
    return 'No se puede cambiar esta cuenta a un tipo que no recibe ingresos '
        'porque tiene ${_recordLabel(counts.incomeCount, 'ingreso', 'ingresos')} '
        'vinculados.';
  }

  @override
  String toString() => message;
}

String _recordLabel(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}
