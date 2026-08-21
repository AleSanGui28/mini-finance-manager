import 'package:drift/drift.dart';

class IncomesTable extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('crc'))();
  TextColumn get paymentAccountId => text().nullable()();
  TextColumn get category => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
