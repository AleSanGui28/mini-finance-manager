import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/shared/domain/money_currency.dart';

void main() {
  group('MoneyCurrency', () {
    test('crc has correct label and symbol', () {
      expect(MoneyCurrency.crc.label, 'Colones');
      expect(MoneyCurrency.crc.symbol, '₡');
    });

    test('usd has correct label and symbol', () {
      expect(MoneyCurrency.usd.label, 'Dollars');
      expect(MoneyCurrency.usd.symbol, r'$');
    });

    test('all currencies have unique labels and symbols', () {
      final labels = MoneyCurrency.values.map((currency) => currency.label);
      final symbols = MoneyCurrency.values.map((currency) => currency.symbol);

      expect(labels.toSet().length, MoneyCurrency.values.length);
      expect(symbols.toSet().length, MoneyCurrency.values.length);
    });
  });
}
