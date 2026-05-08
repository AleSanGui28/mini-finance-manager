enum PaymentAccountType { bankAccount, debitCard, creditCard, cash, other }

extension PaymentAccountTypeExtension on PaymentAccountType {
  String get label {
    switch (this) {
      case PaymentAccountType.bankAccount:
        return 'Bank Account';
      case PaymentAccountType.debitCard:
        return 'Debit Card';
      case PaymentAccountType.creditCard:
        return 'Credit Card';
      case PaymentAccountType.cash:
        return 'Cash';
      case PaymentAccountType.other:
        return 'Other';
    }
  }

  bool get canReceiveIncome {
    switch (this) {
      case PaymentAccountType.bankAccount:
      case PaymentAccountType.debitCard:
      case PaymentAccountType.cash:
        return true;
      case PaymentAccountType.creditCard:
      case PaymentAccountType.other:
        return false;
    }
  }
}
