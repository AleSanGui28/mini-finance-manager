enum MoneyCurrency { crc, usd }

extension MoneyCurrencyExtension on MoneyCurrency {
  String get label {
    switch (this) {
      case MoneyCurrency.crc:
        return 'Colones';
      case MoneyCurrency.usd:
        return 'Dollars';
    }
  }

  String get symbol {
    switch (this) {
      case MoneyCurrency.crc:
        return '₡';
      case MoneyCurrency.usd:
        return r'$';
    }
  }
}
