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
}
