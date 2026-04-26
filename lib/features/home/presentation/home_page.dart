import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../incomes/data/repository/income_repository.dart';
import '../../incomes/domain/income.dart';
import '../../incomes/presentation/incomes_page.dart';
import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../../personal/presentation/personal_page.dart';
import '../../expenses/data/repository/expense_repository.dart';
import '../../expenses/domain/expense.dart' as expense_domain;
import '../../expenses/presentation/expenses_page.dart';

class HomePage extends StatefulWidget {
  final IncomeRepository? incomeRepository;
  final PaymentAccountRepository? paymentAccountRepository;
  final ExpenseRepository? expenseRepository;

  const HomePage({
    super.key,
    this.incomeRepository,
    this.paymentAccountRepository,
    this.expenseRepository,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final IncomeRepository _incomeRepository;
  late final PaymentAccountRepository _paymentAccountRepository;
  late final ExpenseRepository _expenseRepository;

  @override
  void initState() {
    super.initState();
    final database = AppDatabase();
    _incomeRepository = widget.incomeRepository ?? IncomeRepository(database);
    _paymentAccountRepository =
        widget.paymentAccountRepository ?? PaymentAccountRepository(database);
    _expenseRepository =
        widget.expenseRepository ?? ExpenseRepository(database);
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
            final totalAmount = incomes.fold<double>(
              0,
              (sum, income) => sum + income.amount,
            );

            return StreamBuilder<List<PaymentAccount>>(
              stream: _paymentAccountRepository.watchPaymentAccounts(),
              builder: (context, accountSnapshot) {
                final accounts = accountSnapshot.data ?? [];

                return StreamBuilder<List<expense_domain.Expense>>(
                  stream: _expenseRepository.watchExpenses(),
                  builder: (context, expenseSnapshot) {
                    final expenses = expenseSnapshot.data ?? [];
                    final totalExpenses = expenses.fold<double>(
                      0,
                      (sum, expense) => sum + expense.amount,
                    );

                    return Column(
                      children: [
                        // Ingresos module card
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    IncomesPage(repository: _incomeRepository),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                    '₡${totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Cuentas de Pago',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Icon(
                                        Icons.account_balance,
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${accounts.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${accounts.length} cuenta${accounts.length != 1 ? 's' : ''}',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                    '₡${totalExpenses.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                        Expanded(
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
        ),
      ),
    );
  }
}
