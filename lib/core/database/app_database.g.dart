// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $IncomesTableTable extends IncomesTable
    with TableInfo<$IncomesTableTable, IncomesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('crc'),
  );
  static const VerificationMeta _paymentAccountIdMeta = const VerificationMeta(
    'paymentAccountId',
  );
  @override
  late final GeneratedColumn<String> paymentAccountId = GeneratedColumn<String>(
    'payment_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    currency,
    paymentAccountId,
    category,
    date,
    description,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('payment_account_id')) {
      context.handle(
        _paymentAccountIdMeta,
        paymentAccountId.isAcceptableOrUnknown(
          data['payment_account_id']!,
          _paymentAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      paymentAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_account_id'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IncomesTableTable createAlias(String alias) {
    return $IncomesTableTable(attachedDatabase, alias);
  }
}

class IncomesTableData extends DataClass
    implements Insertable<IncomesTableData> {
  final String id;
  final double amount;
  final String currency;
  final String? paymentAccountId;
  final String category;
  final DateTime date;
  final String description;
  final DateTime createdAt;
  const IncomesTableData({
    required this.id,
    required this.amount,
    required this.currency,
    this.paymentAccountId,
    required this.category,
    required this.date,
    required this.description,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || paymentAccountId != null) {
      map['payment_account_id'] = Variable<String>(paymentAccountId);
    }
    map['category'] = Variable<String>(category);
    map['date'] = Variable<DateTime>(date);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IncomesTableCompanion toCompanion(bool nullToAbsent) {
    return IncomesTableCompanion(
      id: Value(id),
      amount: Value(amount),
      currency: Value(currency),
      paymentAccountId: paymentAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentAccountId),
      category: Value(category),
      date: Value(date),
      description: Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory IncomesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomesTableData(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      paymentAccountId: serializer.fromJson<String?>(json['paymentAccountId']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'paymentAccountId': serializer.toJson<String?>(paymentAccountId),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IncomesTableData copyWith({
    String? id,
    double? amount,
    String? currency,
    Value<String?> paymentAccountId = const Value.absent(),
    String? category,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) => IncomesTableData(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    paymentAccountId: paymentAccountId.present
        ? paymentAccountId.value
        : this.paymentAccountId,
    category: category ?? this.category,
    date: date ?? this.date,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
  );
  IncomesTableData copyWithCompanion(IncomesTableCompanion data) {
    return IncomesTableData(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentAccountId: data.paymentAccountId.present
          ? data.paymentAccountId.value
          : this.paymentAccountId,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomesTableData(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('paymentAccountId: $paymentAccountId, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    currency,
    paymentAccountId,
    category,
    date,
    description,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomesTableData &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.paymentAccountId == this.paymentAccountId &&
          other.category == this.category &&
          other.date == this.date &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class IncomesTableCompanion extends UpdateCompanion<IncomesTableData> {
  final Value<String> id;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String?> paymentAccountId;
  final Value<String> category;
  final Value<DateTime> date;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IncomesTableCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentAccountId = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomesTableCompanion.insert({
    required String id,
    required double amount,
    this.currency = const Value.absent(),
    this.paymentAccountId = const Value.absent(),
    required String category,
    required DateTime date,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       category = Value(category),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<IncomesTableData> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? paymentAccountId,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (paymentAccountId != null) 'payment_account_id': paymentAccountId,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomesTableCompanion copyWith({
    Value<String>? id,
    Value<double>? amount,
    Value<String>? currency,
    Value<String?>? paymentAccountId,
    Value<String>? category,
    Value<DateTime>? date,
    Value<String>? description,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IncomesTableCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentAccountId.present) {
      map['payment_account_id'] = Variable<String>(paymentAccountId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomesTableCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('paymentAccountId: $paymentAccountId, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentAccountsTableTable extends PaymentAccountsTable
    with TableInfo<$PaymentAccountsTableTable, PaymentAccountsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentAccountsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closingDayOfMonthMeta = const VerificationMeta(
    'closingDayOfMonth',
  );
  @override
  late final GeneratedColumn<int> closingDayOfMonth = GeneratedColumn<int>(
    'closing_day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardLastDigitsMeta = const VerificationMeta(
    'cardLastDigits',
  );
  @override
  late final GeneratedColumn<String> cardLastDigits = GeneratedColumn<String>(
    'card_last_digits',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ibanMeta = const VerificationMeta('iban');
  @override
  late final GeneratedColumn<String> iban = GeneratedColumn<String>(
    'iban',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankName,
    alias,
    type,
    closingDayOfMonth,
    createdAt,
    cardLastDigits,
    iban,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_accounts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentAccountsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('closing_day_of_month')) {
      context.handle(
        _closingDayOfMonthMeta,
        closingDayOfMonth.isAcceptableOrUnknown(
          data['closing_day_of_month']!,
          _closingDayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('card_last_digits')) {
      context.handle(
        _cardLastDigitsMeta,
        cardLastDigits.isAcceptableOrUnknown(
          data['card_last_digits']!,
          _cardLastDigitsMeta,
        ),
      );
    }
    if (data.containsKey('iban')) {
      context.handle(
        _ibanMeta,
        iban.isAcceptableOrUnknown(data['iban']!, _ibanMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentAccountsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentAccountsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      closingDayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closing_day_of_month'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      cardLastDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_last_digits'],
      ),
      iban: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iban'],
      ),
    );
  }

  @override
  $PaymentAccountsTableTable createAlias(String alias) {
    return $PaymentAccountsTableTable(attachedDatabase, alias);
  }
}

class PaymentAccountsTableData extends DataClass
    implements Insertable<PaymentAccountsTableData> {
  final String id;
  final String bankName;
  final String alias;
  final String type;
  final int? closingDayOfMonth;
  final DateTime createdAt;
  final String? cardLastDigits;
  final String? iban;
  const PaymentAccountsTableData({
    required this.id,
    required this.bankName,
    required this.alias,
    required this.type,
    this.closingDayOfMonth,
    required this.createdAt,
    this.cardLastDigits,
    this.iban,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bank_name'] = Variable<String>(bankName);
    map['alias'] = Variable<String>(alias);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || closingDayOfMonth != null) {
      map['closing_day_of_month'] = Variable<int>(closingDayOfMonth);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || cardLastDigits != null) {
      map['card_last_digits'] = Variable<String>(cardLastDigits);
    }
    if (!nullToAbsent || iban != null) {
      map['iban'] = Variable<String>(iban);
    }
    return map;
  }

  PaymentAccountsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentAccountsTableCompanion(
      id: Value(id),
      bankName: Value(bankName),
      alias: Value(alias),
      type: Value(type),
      closingDayOfMonth: closingDayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(closingDayOfMonth),
      createdAt: Value(createdAt),
      cardLastDigits: cardLastDigits == null && nullToAbsent
          ? const Value.absent()
          : Value(cardLastDigits),
      iban: iban == null && nullToAbsent ? const Value.absent() : Value(iban),
    );
  }

  factory PaymentAccountsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentAccountsTableData(
      id: serializer.fromJson<String>(json['id']),
      bankName: serializer.fromJson<String>(json['bankName']),
      alias: serializer.fromJson<String>(json['alias']),
      type: serializer.fromJson<String>(json['type']),
      closingDayOfMonth: serializer.fromJson<int?>(json['closingDayOfMonth']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cardLastDigits: serializer.fromJson<String?>(json['cardLastDigits']),
      iban: serializer.fromJson<String?>(json['iban']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bankName': serializer.toJson<String>(bankName),
      'alias': serializer.toJson<String>(alias),
      'type': serializer.toJson<String>(type),
      'closingDayOfMonth': serializer.toJson<int?>(closingDayOfMonth),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cardLastDigits': serializer.toJson<String?>(cardLastDigits),
      'iban': serializer.toJson<String?>(iban),
    };
  }

  PaymentAccountsTableData copyWith({
    String? id,
    String? bankName,
    String? alias,
    String? type,
    Value<int?> closingDayOfMonth = const Value.absent(),
    DateTime? createdAt,
    Value<String?> cardLastDigits = const Value.absent(),
    Value<String?> iban = const Value.absent(),
  }) => PaymentAccountsTableData(
    id: id ?? this.id,
    bankName: bankName ?? this.bankName,
    alias: alias ?? this.alias,
    type: type ?? this.type,
    closingDayOfMonth: closingDayOfMonth.present
        ? closingDayOfMonth.value
        : this.closingDayOfMonth,
    createdAt: createdAt ?? this.createdAt,
    cardLastDigits: cardLastDigits.present
        ? cardLastDigits.value
        : this.cardLastDigits,
    iban: iban.present ? iban.value : this.iban,
  );
  PaymentAccountsTableData copyWithCompanion(
    PaymentAccountsTableCompanion data,
  ) {
    return PaymentAccountsTableData(
      id: data.id.present ? data.id.value : this.id,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      alias: data.alias.present ? data.alias.value : this.alias,
      type: data.type.present ? data.type.value : this.type,
      closingDayOfMonth: data.closingDayOfMonth.present
          ? data.closingDayOfMonth.value
          : this.closingDayOfMonth,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cardLastDigits: data.cardLastDigits.present
          ? data.cardLastDigits.value
          : this.cardLastDigits,
      iban: data.iban.present ? data.iban.value : this.iban,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAccountsTableData(')
          ..write('id: $id, ')
          ..write('bankName: $bankName, ')
          ..write('alias: $alias, ')
          ..write('type: $type, ')
          ..write('closingDayOfMonth: $closingDayOfMonth, ')
          ..write('createdAt: $createdAt, ')
          ..write('cardLastDigits: $cardLastDigits, ')
          ..write('iban: $iban')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankName,
    alias,
    type,
    closingDayOfMonth,
    createdAt,
    cardLastDigits,
    iban,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentAccountsTableData &&
          other.id == this.id &&
          other.bankName == this.bankName &&
          other.alias == this.alias &&
          other.type == this.type &&
          other.closingDayOfMonth == this.closingDayOfMonth &&
          other.createdAt == this.createdAt &&
          other.cardLastDigits == this.cardLastDigits &&
          other.iban == this.iban);
}

class PaymentAccountsTableCompanion
    extends UpdateCompanion<PaymentAccountsTableData> {
  final Value<String> id;
  final Value<String> bankName;
  final Value<String> alias;
  final Value<String> type;
  final Value<int?> closingDayOfMonth;
  final Value<DateTime> createdAt;
  final Value<String?> cardLastDigits;
  final Value<String?> iban;
  final Value<int> rowid;
  const PaymentAccountsTableCompanion({
    this.id = const Value.absent(),
    this.bankName = const Value.absent(),
    this.alias = const Value.absent(),
    this.type = const Value.absent(),
    this.closingDayOfMonth = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cardLastDigits = const Value.absent(),
    this.iban = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentAccountsTableCompanion.insert({
    required String id,
    required String bankName,
    required String alias,
    required String type,
    this.closingDayOfMonth = const Value.absent(),
    required DateTime createdAt,
    this.cardLastDigits = const Value.absent(),
    this.iban = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bankName = Value(bankName),
       alias = Value(alias),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<PaymentAccountsTableData> custom({
    Expression<String>? id,
    Expression<String>? bankName,
    Expression<String>? alias,
    Expression<String>? type,
    Expression<int>? closingDayOfMonth,
    Expression<DateTime>? createdAt,
    Expression<String>? cardLastDigits,
    Expression<String>? iban,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankName != null) 'bank_name': bankName,
      if (alias != null) 'alias': alias,
      if (type != null) 'type': type,
      if (closingDayOfMonth != null) 'closing_day_of_month': closingDayOfMonth,
      if (createdAt != null) 'created_at': createdAt,
      if (cardLastDigits != null) 'card_last_digits': cardLastDigits,
      if (iban != null) 'iban': iban,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentAccountsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? bankName,
    Value<String>? alias,
    Value<String>? type,
    Value<int?>? closingDayOfMonth,
    Value<DateTime>? createdAt,
    Value<String?>? cardLastDigits,
    Value<String?>? iban,
    Value<int>? rowid,
  }) {
    return PaymentAccountsTableCompanion(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      alias: alias ?? this.alias,
      type: type ?? this.type,
      closingDayOfMonth: closingDayOfMonth ?? this.closingDayOfMonth,
      createdAt: createdAt ?? this.createdAt,
      cardLastDigits: cardLastDigits ?? this.cardLastDigits,
      iban: iban ?? this.iban,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (closingDayOfMonth.present) {
      map['closing_day_of_month'] = Variable<int>(closingDayOfMonth.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cardLastDigits.present) {
      map['card_last_digits'] = Variable<String>(cardLastDigits.value);
    }
    if (iban.present) {
      map['iban'] = Variable<String>(iban.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAccountsTableCompanion(')
          ..write('id: $id, ')
          ..write('bankName: $bankName, ')
          ..write('alias: $alias, ')
          ..write('type: $type, ')
          ..write('closingDayOfMonth: $closingDayOfMonth, ')
          ..write('createdAt: $createdAt, ')
          ..write('cardLastDigits: $cardLastDigits, ')
          ..write('iban: $iban, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTableTable extends ExpensesTable
    with TableInfo<$ExpensesTableTable, ExpensesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('crc'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentAccountIdMeta = const VerificationMeta(
    'paymentAccountId',
  );
  @override
  late final GeneratedColumn<String> paymentAccountId = GeneratedColumn<String>(
    'payment_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fixedCategoryMeta = const VerificationMeta(
    'fixedCategory',
  );
  @override
  late final GeneratedColumn<String> fixedCategory = GeneratedColumn<String>(
    'fixed_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customFrequencyDescriptionMeta =
      const VerificationMeta('customFrequencyDescription');
  @override
  late final GeneratedColumn<String> customFrequencyDescription =
      GeneratedColumn<String>(
        'custom_frequency_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    currency,
    type,
    paymentAccountId,
    date,
    createdAt,
    description,
    fixedCategory,
    frequency,
    customFrequencyDescription,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpensesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payment_account_id')) {
      context.handle(
        _paymentAccountIdMeta,
        paymentAccountId.isAcceptableOrUnknown(
          data['payment_account_id']!,
          _paymentAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentAccountIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('fixed_category')) {
      context.handle(
        _fixedCategoryMeta,
        fixedCategory.isAcceptableOrUnknown(
          data['fixed_category']!,
          _fixedCategoryMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('custom_frequency_description')) {
      context.handle(
        _customFrequencyDescriptionMeta,
        customFrequencyDescription.isAcceptableOrUnknown(
          data['custom_frequency_description']!,
          _customFrequencyDescriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpensesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpensesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      paymentAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_account_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      fixedCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fixed_category'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      customFrequencyDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_frequency_description'],
      ),
    );
  }

  @override
  $ExpensesTableTable createAlias(String alias) {
    return $ExpensesTableTable(attachedDatabase, alias);
  }
}

class ExpensesTableData extends DataClass
    implements Insertable<ExpensesTableData> {
  final String id;
  final double amount;
  final String currency;
  final String type;
  final String paymentAccountId;
  final DateTime date;
  final DateTime createdAt;
  final String? description;
  final String? fixedCategory;
  final String? frequency;
  final String? customFrequencyDescription;
  const ExpensesTableData({
    required this.id,
    required this.amount,
    required this.currency,
    required this.type,
    required this.paymentAccountId,
    required this.date,
    required this.createdAt,
    this.description,
    this.fixedCategory,
    this.frequency,
    this.customFrequencyDescription,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['type'] = Variable<String>(type);
    map['payment_account_id'] = Variable<String>(paymentAccountId);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || fixedCategory != null) {
      map['fixed_category'] = Variable<String>(fixedCategory);
    }
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    if (!nullToAbsent || customFrequencyDescription != null) {
      map['custom_frequency_description'] = Variable<String>(
        customFrequencyDescription,
      );
    }
    return map;
  }

  ExpensesTableCompanion toCompanion(bool nullToAbsent) {
    return ExpensesTableCompanion(
      id: Value(id),
      amount: Value(amount),
      currency: Value(currency),
      type: Value(type),
      paymentAccountId: Value(paymentAccountId),
      date: Value(date),
      createdAt: Value(createdAt),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      fixedCategory: fixedCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedCategory),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      customFrequencyDescription:
          customFrequencyDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(customFrequencyDescription),
    );
  }

  factory ExpensesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpensesTableData(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      type: serializer.fromJson<String>(json['type']),
      paymentAccountId: serializer.fromJson<String>(json['paymentAccountId']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      description: serializer.fromJson<String?>(json['description']),
      fixedCategory: serializer.fromJson<String?>(json['fixedCategory']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      customFrequencyDescription: serializer.fromJson<String?>(
        json['customFrequencyDescription'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'type': serializer.toJson<String>(type),
      'paymentAccountId': serializer.toJson<String>(paymentAccountId),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'description': serializer.toJson<String?>(description),
      'fixedCategory': serializer.toJson<String?>(fixedCategory),
      'frequency': serializer.toJson<String?>(frequency),
      'customFrequencyDescription': serializer.toJson<String?>(
        customFrequencyDescription,
      ),
    };
  }

  ExpensesTableData copyWith({
    String? id,
    double? amount,
    String? currency,
    String? type,
    String? paymentAccountId,
    DateTime? date,
    DateTime? createdAt,
    Value<String?> description = const Value.absent(),
    Value<String?> fixedCategory = const Value.absent(),
    Value<String?> frequency = const Value.absent(),
    Value<String?> customFrequencyDescription = const Value.absent(),
  }) => ExpensesTableData(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    type: type ?? this.type,
    paymentAccountId: paymentAccountId ?? this.paymentAccountId,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    description: description.present ? description.value : this.description,
    fixedCategory: fixedCategory.present
        ? fixedCategory.value
        : this.fixedCategory,
    frequency: frequency.present ? frequency.value : this.frequency,
    customFrequencyDescription: customFrequencyDescription.present
        ? customFrequencyDescription.value
        : this.customFrequencyDescription,
  );
  ExpensesTableData copyWithCompanion(ExpensesTableCompanion data) {
    return ExpensesTableData(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      type: data.type.present ? data.type.value : this.type,
      paymentAccountId: data.paymentAccountId.present
          ? data.paymentAccountId.value
          : this.paymentAccountId,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      description: data.description.present
          ? data.description.value
          : this.description,
      fixedCategory: data.fixedCategory.present
          ? data.fixedCategory.value
          : this.fixedCategory,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      customFrequencyDescription: data.customFrequencyDescription.present
          ? data.customFrequencyDescription.value
          : this.customFrequencyDescription,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableData(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('type: $type, ')
          ..write('paymentAccountId: $paymentAccountId, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('fixedCategory: $fixedCategory, ')
          ..write('frequency: $frequency, ')
          ..write('customFrequencyDescription: $customFrequencyDescription')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    currency,
    type,
    paymentAccountId,
    date,
    createdAt,
    description,
    fixedCategory,
    frequency,
    customFrequencyDescription,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpensesTableData &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.type == this.type &&
          other.paymentAccountId == this.paymentAccountId &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.description == this.description &&
          other.fixedCategory == this.fixedCategory &&
          other.frequency == this.frequency &&
          other.customFrequencyDescription == this.customFrequencyDescription);
}

class ExpensesTableCompanion extends UpdateCompanion<ExpensesTableData> {
  final Value<String> id;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String> type;
  final Value<String> paymentAccountId;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<String?> description;
  final Value<String?> fixedCategory;
  final Value<String?> frequency;
  final Value<String?> customFrequencyDescription;
  final Value<int> rowid;
  const ExpensesTableCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.type = const Value.absent(),
    this.paymentAccountId = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
    this.fixedCategory = const Value.absent(),
    this.frequency = const Value.absent(),
    this.customFrequencyDescription = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesTableCompanion.insert({
    required String id,
    required double amount,
    this.currency = const Value.absent(),
    required String type,
    required String paymentAccountId,
    required DateTime date,
    required DateTime createdAt,
    this.description = const Value.absent(),
    this.fixedCategory = const Value.absent(),
    this.frequency = const Value.absent(),
    this.customFrequencyDescription = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       type = Value(type),
       paymentAccountId = Value(paymentAccountId),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<ExpensesTableData> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? type,
    Expression<String>? paymentAccountId,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<String>? description,
    Expression<String>? fixedCategory,
    Expression<String>? frequency,
    Expression<String>? customFrequencyDescription,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (type != null) 'type': type,
      if (paymentAccountId != null) 'payment_account_id': paymentAccountId,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (description != null) 'description': description,
      if (fixedCategory != null) 'fixed_category': fixedCategory,
      if (frequency != null) 'frequency': frequency,
      if (customFrequencyDescription != null)
        'custom_frequency_description': customFrequencyDescription,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesTableCompanion copyWith({
    Value<String>? id,
    Value<double>? amount,
    Value<String>? currency,
    Value<String>? type,
    Value<String>? paymentAccountId,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<String?>? description,
    Value<String?>? fixedCategory,
    Value<String?>? frequency,
    Value<String?>? customFrequencyDescription,
    Value<int>? rowid,
  }) {
    return ExpensesTableCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      paymentAccountId: paymentAccountId ?? this.paymentAccountId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      fixedCategory: fixedCategory ?? this.fixedCategory,
      frequency: frequency ?? this.frequency,
      customFrequencyDescription:
          customFrequencyDescription ?? this.customFrequencyDescription,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (paymentAccountId.present) {
      map['payment_account_id'] = Variable<String>(paymentAccountId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (fixedCategory.present) {
      map['fixed_category'] = Variable<String>(fixedCategory.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (customFrequencyDescription.present) {
      map['custom_frequency_description'] = Variable<String>(
        customFrequencyDescription.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('type: $type, ')
          ..write('paymentAccountId: $paymentAccountId, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('fixedCategory: $fixedCategory, ')
          ..write('frequency: $frequency, ')
          ..write('customFrequencyDescription: $customFrequencyDescription, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingGoalsTableTable extends SavingGoalsTable
    with TableInfo<$SavingGoalsTableTable, SavingGoalsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingGoalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    targetAmount,
    targetDate,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saving_goals_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingGoalsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingGoalsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingGoalsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_amount'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SavingGoalsTableTable createAlias(String alias) {
    return $SavingGoalsTableTable(attachedDatabase, alias);
  }
}

class SavingGoalsTableData extends DataClass
    implements Insertable<SavingGoalsTableData> {
  final String id;
  final String title;
  final double targetAmount;
  final DateTime? targetDate;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const SavingGoalsTableData({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.targetDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['target_amount'] = Variable<double>(targetAmount);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SavingGoalsTableCompanion toCompanion(bool nullToAbsent) {
    return SavingGoalsTableCompanion(
      id: Value(id),
      title: Value(title),
      targetAmount: Value(targetAmount),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SavingGoalsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingGoalsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  SavingGoalsTableData copyWith({
    String? id,
    String? title,
    double? targetAmount,
    Value<DateTime?> targetDate = const Value.absent(),
    String? status,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => SavingGoalsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    targetAmount: targetAmount ?? this.targetAmount,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  SavingGoalsTableData copyWithCompanion(SavingGoalsTableCompanion data) {
    return SavingGoalsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingGoalsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    targetAmount,
    targetDate,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingGoalsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.targetAmount == this.targetAmount &&
          other.targetDate == this.targetDate &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavingGoalsTableCompanion extends UpdateCompanion<SavingGoalsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<double> targetAmount;
  final Value<DateTime?> targetDate;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const SavingGoalsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingGoalsTableCompanion.insert({
    required String id,
    required String title,
    required double targetAmount,
    this.targetDate = const Value.absent(),
    required String status,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       targetAmount = Value(targetAmount),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<SavingGoalsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<double>? targetAmount,
    Expression<DateTime>? targetDate,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (targetDate != null) 'target_date': targetDate,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingGoalsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<double>? targetAmount,
    Value<DateTime?>? targetDate,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return SavingGoalsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingGoalsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IncomesTableTable incomesTable = $IncomesTableTable(this);
  late final $PaymentAccountsTableTable paymentAccountsTable =
      $PaymentAccountsTableTable(this);
  late final $ExpensesTableTable expensesTable = $ExpensesTableTable(this);
  late final $SavingGoalsTableTable savingGoalsTable = $SavingGoalsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    incomesTable,
    paymentAccountsTable,
    expensesTable,
    savingGoalsTable,
  ];
}

typedef $$IncomesTableTableCreateCompanionBuilder =
    IncomesTableCompanion Function({
      required String id,
      required double amount,
      Value<String> currency,
      Value<String?> paymentAccountId,
      required String category,
      required DateTime date,
      Value<String> description,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$IncomesTableTableUpdateCompanionBuilder =
    IncomesTableCompanion Function({
      Value<String> id,
      Value<double> amount,
      Value<String> currency,
      Value<String?> paymentAccountId,
      Value<String> category,
      Value<DateTime> date,
      Value<String> description,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$IncomesTableTableFilterComposer
    extends Composer<_$AppDatabase, $IncomesTableTable> {
  $$IncomesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentAccountId => $composableBuilder(
    column: $table.paymentAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IncomesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomesTableTable> {
  $$IncomesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentAccountId => $composableBuilder(
    column: $table.paymentAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomesTableTable> {
  $$IncomesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paymentAccountId => $composableBuilder(
    column: $table.paymentAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IncomesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomesTableTable,
          IncomesTableData,
          $$IncomesTableTableFilterComposer,
          $$IncomesTableTableOrderingComposer,
          $$IncomesTableTableAnnotationComposer,
          $$IncomesTableTableCreateCompanionBuilder,
          $$IncomesTableTableUpdateCompanionBuilder,
          (
            IncomesTableData,
            BaseReferences<_$AppDatabase, $IncomesTableTable, IncomesTableData>,
          ),
          IncomesTableData,
          PrefetchHooks Function()
        > {
  $$IncomesTableTableTableManager(_$AppDatabase db, $IncomesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> paymentAccountId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomesTableCompanion(
                id: id,
                amount: amount,
                currency: currency,
                paymentAccountId: paymentAccountId,
                category: category,
                date: date,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double amount,
                Value<String> currency = const Value.absent(),
                Value<String?> paymentAccountId = const Value.absent(),
                required String category,
                required DateTime date,
                Value<String> description = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IncomesTableCompanion.insert(
                id: id,
                amount: amount,
                currency: currency,
                paymentAccountId: paymentAccountId,
                category: category,
                date: date,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IncomesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomesTableTable,
      IncomesTableData,
      $$IncomesTableTableFilterComposer,
      $$IncomesTableTableOrderingComposer,
      $$IncomesTableTableAnnotationComposer,
      $$IncomesTableTableCreateCompanionBuilder,
      $$IncomesTableTableUpdateCompanionBuilder,
      (
        IncomesTableData,
        BaseReferences<_$AppDatabase, $IncomesTableTable, IncomesTableData>,
      ),
      IncomesTableData,
      PrefetchHooks Function()
    >;
typedef $$PaymentAccountsTableTableCreateCompanionBuilder =
    PaymentAccountsTableCompanion Function({
      required String id,
      required String bankName,
      required String alias,
      required String type,
      Value<int?> closingDayOfMonth,
      required DateTime createdAt,
      Value<String?> cardLastDigits,
      Value<String?> iban,
      Value<int> rowid,
    });
typedef $$PaymentAccountsTableTableUpdateCompanionBuilder =
    PaymentAccountsTableCompanion Function({
      Value<String> id,
      Value<String> bankName,
      Value<String> alias,
      Value<String> type,
      Value<int?> closingDayOfMonth,
      Value<DateTime> createdAt,
      Value<String?> cardLastDigits,
      Value<String?> iban,
      Value<int> rowid,
    });

class $$PaymentAccountsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentAccountsTableTable> {
  $$PaymentAccountsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closingDayOfMonth => $composableBuilder(
    column: $table.closingDayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardLastDigits => $composableBuilder(
    column: $table.cardLastDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iban => $composableBuilder(
    column: $table.iban,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentAccountsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentAccountsTableTable> {
  $$PaymentAccountsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closingDayOfMonth => $composableBuilder(
    column: $table.closingDayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardLastDigits => $composableBuilder(
    column: $table.cardLastDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iban => $composableBuilder(
    column: $table.iban,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentAccountsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentAccountsTableTable> {
  $$PaymentAccountsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get closingDayOfMonth => $composableBuilder(
    column: $table.closingDayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get cardLastDigits => $composableBuilder(
    column: $table.cardLastDigits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iban =>
      $composableBuilder(column: $table.iban, builder: (column) => column);
}

class $$PaymentAccountsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentAccountsTableTable,
          PaymentAccountsTableData,
          $$PaymentAccountsTableTableFilterComposer,
          $$PaymentAccountsTableTableOrderingComposer,
          $$PaymentAccountsTableTableAnnotationComposer,
          $$PaymentAccountsTableTableCreateCompanionBuilder,
          $$PaymentAccountsTableTableUpdateCompanionBuilder,
          (
            PaymentAccountsTableData,
            BaseReferences<
              _$AppDatabase,
              $PaymentAccountsTableTable,
              PaymentAccountsTableData
            >,
          ),
          PaymentAccountsTableData,
          PrefetchHooks Function()
        > {
  $$PaymentAccountsTableTableTableManager(
    _$AppDatabase db,
    $PaymentAccountsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentAccountsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentAccountsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PaymentAccountsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bankName = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> closingDayOfMonth = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> cardLastDigits = const Value.absent(),
                Value<String?> iban = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentAccountsTableCompanion(
                id: id,
                bankName: bankName,
                alias: alias,
                type: type,
                closingDayOfMonth: closingDayOfMonth,
                createdAt: createdAt,
                cardLastDigits: cardLastDigits,
                iban: iban,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bankName,
                required String alias,
                required String type,
                Value<int?> closingDayOfMonth = const Value.absent(),
                required DateTime createdAt,
                Value<String?> cardLastDigits = const Value.absent(),
                Value<String?> iban = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentAccountsTableCompanion.insert(
                id: id,
                bankName: bankName,
                alias: alias,
                type: type,
                closingDayOfMonth: closingDayOfMonth,
                createdAt: createdAt,
                cardLastDigits: cardLastDigits,
                iban: iban,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentAccountsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentAccountsTableTable,
      PaymentAccountsTableData,
      $$PaymentAccountsTableTableFilterComposer,
      $$PaymentAccountsTableTableOrderingComposer,
      $$PaymentAccountsTableTableAnnotationComposer,
      $$PaymentAccountsTableTableCreateCompanionBuilder,
      $$PaymentAccountsTableTableUpdateCompanionBuilder,
      (
        PaymentAccountsTableData,
        BaseReferences<
          _$AppDatabase,
          $PaymentAccountsTableTable,
          PaymentAccountsTableData
        >,
      ),
      PaymentAccountsTableData,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableTableCreateCompanionBuilder =
    ExpensesTableCompanion Function({
      required String id,
      required double amount,
      Value<String> currency,
      required String type,
      required String paymentAccountId,
      required DateTime date,
      required DateTime createdAt,
      Value<String?> description,
      Value<String?> fixedCategory,
      Value<String?> frequency,
      Value<String?> customFrequencyDescription,
      Value<int> rowid,
    });
typedef $$ExpensesTableTableUpdateCompanionBuilder =
    ExpensesTableCompanion Function({
      Value<String> id,
      Value<double> amount,
      Value<String> currency,
      Value<String> type,
      Value<String> paymentAccountId,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<String?> description,
      Value<String?> fixedCategory,
      Value<String?> frequency,
      Value<String?> customFrequencyDescription,
      Value<int> rowid,
    });

class $$ExpensesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentAccountId => $composableBuilder(
    column: $table.paymentAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fixedCategory => $composableBuilder(
    column: $table.fixedCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customFrequencyDescription => $composableBuilder(
    column: $table.customFrequencyDescription,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentAccountId => $composableBuilder(
    column: $table.paymentAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixedCategory => $composableBuilder(
    column: $table.fixedCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customFrequencyDescription => $composableBuilder(
    column: $table.customFrequencyDescription,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get paymentAccountId => $composableBuilder(
    column: $table.paymentAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fixedCategory => $composableBuilder(
    column: $table.fixedCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get customFrequencyDescription => $composableBuilder(
    column: $table.customFrequencyDescription,
    builder: (column) => column,
  );
}

class $$ExpensesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTableTable,
          ExpensesTableData,
          $$ExpensesTableTableFilterComposer,
          $$ExpensesTableTableOrderingComposer,
          $$ExpensesTableTableAnnotationComposer,
          $$ExpensesTableTableCreateCompanionBuilder,
          $$ExpensesTableTableUpdateCompanionBuilder,
          (
            ExpensesTableData,
            BaseReferences<
              _$AppDatabase,
              $ExpensesTableTable,
              ExpensesTableData
            >,
          ),
          ExpensesTableData,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableTableManager(_$AppDatabase db, $ExpensesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> paymentAccountId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> fixedCategory = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> customFrequencyDescription =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion(
                id: id,
                amount: amount,
                currency: currency,
                type: type,
                paymentAccountId: paymentAccountId,
                date: date,
                createdAt: createdAt,
                description: description,
                fixedCategory: fixedCategory,
                frequency: frequency,
                customFrequencyDescription: customFrequencyDescription,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double amount,
                Value<String> currency = const Value.absent(),
                required String type,
                required String paymentAccountId,
                required DateTime date,
                required DateTime createdAt,
                Value<String?> description = const Value.absent(),
                Value<String?> fixedCategory = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> customFrequencyDescription =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion.insert(
                id: id,
                amount: amount,
                currency: currency,
                type: type,
                paymentAccountId: paymentAccountId,
                date: date,
                createdAt: createdAt,
                description: description,
                fixedCategory: fixedCategory,
                frequency: frequency,
                customFrequencyDescription: customFrequencyDescription,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTableTable,
      ExpensesTableData,
      $$ExpensesTableTableFilterComposer,
      $$ExpensesTableTableOrderingComposer,
      $$ExpensesTableTableAnnotationComposer,
      $$ExpensesTableTableCreateCompanionBuilder,
      $$ExpensesTableTableUpdateCompanionBuilder,
      (
        ExpensesTableData,
        BaseReferences<_$AppDatabase, $ExpensesTableTable, ExpensesTableData>,
      ),
      ExpensesTableData,
      PrefetchHooks Function()
    >;
typedef $$SavingGoalsTableTableCreateCompanionBuilder =
    SavingGoalsTableCompanion Function({
      required String id,
      required String title,
      required double targetAmount,
      Value<DateTime?> targetDate,
      required String status,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$SavingGoalsTableTableUpdateCompanionBuilder =
    SavingGoalsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<double> targetAmount,
      Value<DateTime?> targetDate,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$SavingGoalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavingGoalsTableTable> {
  $$SavingGoalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingGoalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingGoalsTableTable> {
  $$SavingGoalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingGoalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingGoalsTableTable> {
  $$SavingGoalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavingGoalsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingGoalsTableTable,
          SavingGoalsTableData,
          $$SavingGoalsTableTableFilterComposer,
          $$SavingGoalsTableTableOrderingComposer,
          $$SavingGoalsTableTableAnnotationComposer,
          $$SavingGoalsTableTableCreateCompanionBuilder,
          $$SavingGoalsTableTableUpdateCompanionBuilder,
          (
            SavingGoalsTableData,
            BaseReferences<
              _$AppDatabase,
              $SavingGoalsTableTable,
              SavingGoalsTableData
            >,
          ),
          SavingGoalsTableData,
          PrefetchHooks Function()
        > {
  $$SavingGoalsTableTableTableManager(
    _$AppDatabase db,
    $SavingGoalsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingGoalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingGoalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingGoalsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingGoalsTableCompanion(
                id: id,
                title: title,
                targetAmount: targetAmount,
                targetDate: targetDate,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required double targetAmount,
                Value<DateTime?> targetDate = const Value.absent(),
                required String status,
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingGoalsTableCompanion.insert(
                id: id,
                title: title,
                targetAmount: targetAmount,
                targetDate: targetDate,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingGoalsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingGoalsTableTable,
      SavingGoalsTableData,
      $$SavingGoalsTableTableFilterComposer,
      $$SavingGoalsTableTableOrderingComposer,
      $$SavingGoalsTableTableAnnotationComposer,
      $$SavingGoalsTableTableCreateCompanionBuilder,
      $$SavingGoalsTableTableUpdateCompanionBuilder,
      (
        SavingGoalsTableData,
        BaseReferences<
          _$AppDatabase,
          $SavingGoalsTableTable,
          SavingGoalsTableData
        >,
      ),
      SavingGoalsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IncomesTableTableTableManager get incomesTable =>
      $$IncomesTableTableTableManager(_db, _db.incomesTable);
  $$PaymentAccountsTableTableTableManager get paymentAccountsTable =>
      $$PaymentAccountsTableTableTableManager(_db, _db.paymentAccountsTable);
  $$ExpensesTableTableTableManager get expensesTable =>
      $$ExpensesTableTableTableManager(_db, _db.expensesTable);
  $$SavingGoalsTableTableTableManager get savingGoalsTable =>
      $$SavingGoalsTableTableTableManager(_db, _db.savingGoalsTable);
}
