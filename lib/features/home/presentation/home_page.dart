import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../incomes/data/repository/income_repository.dart';
import '../../incomes/domain/income.dart';
import '../../incomes/presentation/incomes_page.dart';
import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/data/repository/saving_goal_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../../personal/domain/saving_goal.dart';
import '../../personal/presentation/personal_page.dart';
import '../../expenses/data/repository/expense_repository.dart';
import '../../expenses/domain/expense.dart' as expense_domain;
import '../../expenses/presentation/expenses_page.dart';
import '../../shared/domain/money_currency.dart';

class HomePage extends StatefulWidget {
  final IncomeRepository? incomeRepository;
  final PaymentAccountRepository? paymentAccountRepository;
  final ExpenseRepository? expenseRepository;
  final SavingGoalRepository? savingGoalRepository;

  const HomePage({
    super.key,
    this.incomeRepository,
    this.paymentAccountRepository,
    this.expenseRepository,
    this.savingGoalRepository,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppDatabase? _database;
  IncomeRepository? _incomeRepositoryInstance;
  PaymentAccountRepository? _paymentAccountRepositoryInstance;
  ExpenseRepository? _expenseRepositoryInstance;
  SavingGoalRepository? _savingGoalRepositoryInstance;

  IncomeRepository get _incomeRepository {
    _ensureRepositories();
    return _incomeRepositoryInstance!;
  }

  PaymentAccountRepository get _paymentAccountRepository {
    _ensureRepositories();
    return _paymentAccountRepositoryInstance!;
  }

  ExpenseRepository get _expenseRepository {
    _ensureRepositories();
    return _expenseRepositoryInstance!;
  }

  SavingGoalRepository get _savingGoalRepository {
    _ensureRepositories();
    return _savingGoalRepositoryInstance!;
  }

  @override
  void initState() {
    super.initState();
    _ensureRepositories();
  }

  void _ensureRepositories() {
    if (_incomeRepositoryInstance != null &&
        _paymentAccountRepositoryInstance != null &&
        _expenseRepositoryInstance != null &&
        _savingGoalRepositoryInstance != null) {
      return;
    }

    final needsDatabase =
        widget.incomeRepository == null ||
        widget.paymentAccountRepository == null ||
        widget.expenseRepository == null ||
        widget.savingGoalRepository == null;
    if (needsDatabase && _database == null) {
      _database = AppDatabase();
    }

    _incomeRepositoryInstance ??=
        widget.incomeRepository ?? IncomeRepository(_database!);
    _paymentAccountRepositoryInstance ??=
        widget.paymentAccountRepository ?? PaymentAccountRepository(_database!);
    _expenseRepositoryInstance ??=
        widget.expenseRepository ?? ExpenseRepository(_database!);
    _savingGoalRepositoryInstance ??=
        widget.savingGoalRepository ?? SavingGoalRepository(_database!);
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Finance Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<Income>>(
          stream: _incomeRepository.watchIncomes(),
          builder: (context, incomeSnapshot) {
            final incomes = incomeSnapshot.data ?? [];
            final incomeTotalsByCurrency = _incomeTotalsByCurrency(incomes);

            return StreamBuilder<List<PaymentAccount>>(
              stream: _paymentAccountRepository.watchPaymentAccounts(),
              builder: (context, accountSnapshot) {
                final accounts = accountSnapshot.data ?? [];

                return StreamBuilder<List<SavingGoal>>(
                  stream: _savingGoalRepository.watchSavingGoals(),
                  builder: (context, savingGoalSnapshot) {
                    final savingGoals = savingGoalSnapshot.data ?? [];
                    final savingGoalTargetTotal = _savingGoalTargetTotal(
                      savingGoals,
                    );

                    return StreamBuilder<List<expense_domain.Expense>>(
                      stream: _expenseRepository.watchExpenses(),
                      builder: (context, expenseSnapshot) {
                        final expenses = expenseSnapshot.data ?? [];
                        final expenseTotalsByCurrency =
                            _expenseTotalsByCurrency(expenses);

                        return ListView(
                          children: [
                            // Ingresos module card
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => IncomesPage(
                                      repository: _incomeRepository,
                                      paymentAccountRepository:
                                          _paymentAccountRepository,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Ingresos',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Icon(
                                            Icons.trending_up,
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _TotalsText(
                                        totalsByCurrency:
                                            incomeTotalsByCurrency,
                                        primaryFontSize: 36,
                                        secondaryFontSize: 22,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${incomes.length} ingreso${incomes.length != 1 ? 's' : ''}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Personal module card
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PersonalPage(
                                      repository: _paymentAccountRepository,
                                      savingGoalRepository:
                                          _savingGoalRepository,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.teal,
                                        Colors.teal.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Personal',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Icon(
                                            Icons.account_balance_wallet,
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Cuentas de pago',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${accounts.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Ahorros',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${savingGoals.length}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'meta${savingGoals.length != 1 ? 's' : ''}',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                          alpha: 0.75,
                                                        ),
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      savingGoalTargetTotal
                                                          .toStringAsFixed(0),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      'meta total',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                          alpha: 0.75,
                                                        ),
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Expenses module card
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ExpensesPage(
                                      expenseRepository: _expenseRepository,
                                      paymentAccountRepository:
                                          _paymentAccountRepository,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.red,
                                        Colors.red.withValues(alpha: 0.8),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Gastos',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Icon(
                                            Icons.trending_down,
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _TotalsText(
                                        totalsByCurrency:
                                            expenseTotalsByCurrency,
                                        primaryFontSize: 36,
                                        secondaryFontSize: 22,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${expenses.length} gasto${expenses.length != 1 ? 's' : ''}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Additional modules placeholder
                            SizedBox(
                              height: 96,
                              child: Center(
                                child: Text(
                                  'Más módulos próximamente',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Map<MoneyCurrency, double> _incomeTotalsByCurrency(List<Income> incomes) {
    if (incomes.isEmpty) {
      return {MoneyCurrency.crc: 0};
    }

    final totals = <MoneyCurrency, double>{};
    for (final income in incomes) {
      totals.update(
        income.currency,
        (total) => total + income.amount,
        ifAbsent: () => income.amount,
      );
    }

    return totals;
  }

  Map<MoneyCurrency, double> _expenseTotalsByCurrency(
    List<expense_domain.Expense> expenses,
  ) {
    if (expenses.isEmpty) {
      return {MoneyCurrency.crc: 0};
    }

    final totals = <MoneyCurrency, double>{};
    for (final expense in expenses) {
      totals.update(
        expense.currency,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return totals;
  }

  double _savingGoalTargetTotal(List<SavingGoal> savingGoals) {
    return savingGoals.fold<double>(
      0,
      (total, savingGoal) => total + savingGoal.targetAmount,
    );
  }
}

class _PersonalMetric extends StatelessWidget {
  const _PersonalMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TotalsText extends StatelessWidget {
  const _TotalsText({
    required this.totalsByCurrency,
    required this.primaryFontSize,
    required this.secondaryFontSize,
  });

  final Map<MoneyCurrency, double> totalsByCurrency;
  final double primaryFontSize;
  final double secondaryFontSize;

  @override
  Widget build(BuildContext context) {
    final entries = MoneyCurrency.values
        .where(totalsByCurrency.containsKey)
        .map((currency) => MapEntry(currency, totalsByCurrency[currency]!))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          if (index > 0) const SizedBox(height: 4),
          Text(
            '${entries[index].key.symbol}${entries[index].value.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: index == 0 ? primaryFontSize : secondaryFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
