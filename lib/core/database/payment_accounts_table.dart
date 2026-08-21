import 'package:drift/drift.dart';

class PaymentAccountsTable extends Table {
  TextColumn get id => text()();
  TextColumn get bankName => text()();
  TextColumn get alias => text()();
  TextColumn get type => text()();
  IntColumn get closingDayOfMonth => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get cardLastDigits => text().nullable()();
  TextColumn get iban => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
