import '../../expenses/domain/expense.dart';
import '../../incomes/domain/income.dart';
import '../../shared/domain/money_currency.dart';
import 'balance_status.dart';
import 'balance_summary.dart';

class BalanceCalculator {
  const BalanceCalculator._();

  static List<BalanceSummary> build({
    required List<Income> incomes,
    required List<Expense> expenses,
  }) {
    final currencies = <MoneyCurrency>{
      for (final income in incomes) income.currency,
      for (final expense in expenses) expense.currency,
    };

    if (currencies.isEmpty) {
      currencies.add(MoneyCurrency.crc);
    }

    return MoneyCurrency.values
        .where(currencies.contains)
        .map((currency) {
          final totalIncomes = _incomeTotal(incomes, currency);
          final totalExpenses = _expenseTotal(expenses, currency);
          final balance = totalIncomes - totalExpenses;

          return BalanceSummary(
            currency: currency,
            totalIncomes: totalIncomes,
            totalExpenses: totalExpenses,
            balance: balance,
            status: _statusFor(balance),
          );
        })
        .toList(growable: false);
  }

  static double _incomeTotal(List<Income> incomes, MoneyCurrency currency) {
    return incomes
        .where((income) => income.currency == currency)
        .fold<double>(0, (total, income) => total + income.amount);
  }

  static double _expenseTotal(List<Expense> expenses, MoneyCurrency currency) {
    return expenses
        .where((expense) => expense.currency == currency)
        .fold<double>(0, (total, expense) => total + expense.amount);
  }

  static BalanceStatus _statusFor(double balance) {
    if (balance.abs() < 0.000001) {
      return BalanceStatus.neutral;
    }

    return balance > 0 ? BalanceStatus.surplus : BalanceStatus.deficit;
  }
}
