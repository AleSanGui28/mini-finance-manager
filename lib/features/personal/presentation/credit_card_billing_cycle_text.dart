import '../domain/credit_card_billing_cycle.dart';

String formatClosingDayOfMonth(int closingDayOfMonth) {
  return 'Fecha de corte: $closingDayOfMonth';
}

String formatPaymentWindow(int closingDayOfMonth) {
  return 'Rango de pago: ${formatPaymentWindowValue(closingDayOfMonth)}';
}

String formatPaymentWindowValue(int closingDayOfMonth) {
  final cycle = CreditCardBillingCycle(closingDayOfMonth: closingDayOfMonth);
  final nextMonthSuffix = cycle.rollsToNextMonth ? ' del siguiente mes' : '';

  return 'del ${cycle.paymentStartDay} al '
      '${cycle.paymentEndDay}$nextMonthSuffix';
}
