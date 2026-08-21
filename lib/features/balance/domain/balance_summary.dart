import '../../shared/domain/money_currency.dart';
import 'balance_status.dart';

class BalanceSummary {
  const BalanceSummary({
    required this.currency,
    required this.totalIncomes,
    required this.totalExpenses,
    required this.balance,
    required this.status,
  });

  final MoneyCurrency currency;
  final double totalIncomes;
  final double totalExpenses;
  final double balance;
  final BalanceStatus status;
}
