import 'package:drift/drift.dart';

class ExpensesTable extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('crc'))();
  TextColumn get type => text()();
  TextColumn get paymentAccountId => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get description => text().nullable()();
  TextColumn get fixedCategory => text().nullable()();
  TextColumn get frequency => text().nullable()();
  TextColumn get customFrequencyDescription => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
