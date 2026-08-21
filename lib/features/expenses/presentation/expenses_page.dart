import 'package:flutter/material.dart';

import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../../shared/domain/money_currency.dart';
import '../data/repository/expense_repository.dart';
import '../domain/expense.dart';
import '../domain/expense_frequency.dart';
import '../domain/expense_type.dart';
import '../domain/fixed_expense_category.dart';
import 'add_expense_page.dart';
import 'expense_detail_page.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({
    super.key,
    required this.expenseRepository,
    required this.paymentAccountRepository,
  });

  final ExpenseRepository expenseRepository;
  final PaymentAccountRepository paymentAccountRepository;

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final Map<String, ValueNotifier<Offset>> _slideOffsets = {};

  ValueNotifier<Offset> _getOffsetNotifier(String id) {
    return _slideOffsets.putIfAbsent(id, () => ValueNotifier(Offset.zero));
  }

  @override
  void dispose() {
    for (final notifier in _slideOffsets.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _openExpenseEditor(Expense expense) {
    _getOffsetNotifier(expense.id).value = Offset.zero;
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpensePage(
          expenseRepository: widget.expenseRepository,
          paymentAccountRepository: widget.paymentAccountRepository,
          expense: expense,
        ),
      ),
    );
  }

  Future<void> _openExpenseDetail(Expense expense) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseDetailPage(
          expenseRepository: widget.expenseRepository,
          paymentAccountRepository: widget.paymentAccountRepository,
          expense: expense,
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: const Text('Seguro que deseas eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      await widget.expenseRepository.deleteExpense(expense.id);

      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto eliminado')));
      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos'), elevation: 0),
      body: StreamBuilder<List<Expense>>(
        stream: widget.expenseRepository.watchExpenses(),
        builder: (context, expenseSnapshot) {
          if (expenseSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseSnapshot.hasError) {
            return Center(child: Text('Error: ${expenseSnapshot.error}'));
          }

          final expenses = expenseSnapshot.data ?? [];
          final totalsByCurrency = _totalsByCurrency(expenses);

          return StreamBuilder<List<PaymentAccount>>(
            stream: widget.paymentAccountRepository.watchPaymentAccounts(),
            builder: (context, accountSnapshot) {
              final accounts = accountSnapshot.data ?? [];
              final accountsById = {
                for (final account in accounts) account.id: account,
              };

              return Column(
                children: [
                  _buildSummary(totalsByCurrency),
                  if (expenses.isEmpty)
                    _buildEmptyState()
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          final account =
                              accountsById[expense.paymentAccountId];

                          return _buildExpenseRow(context, expense, account);
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddExpensePage(
                expenseRepository: widget.expenseRepository,
                paymentAccountRepository: widget.paymentAccountRepository,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar gasto'),
      ),
    );
  }

  Widget _buildSummary(Map<MoneyCurrency, double> totalsByCurrency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total de gastos',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ..._buildTotalTexts(totalsByCurrency),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.red.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay gastos registrados',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseRow(
    BuildContext context,
    Expense expense,
    PaymentAccount? account,
  ) {
    final offsetNotifier = _getOffsetNotifier(expense.id);

    return ValueListenableBuilder<Offset>(
      valueListenable: offsetNotifier,
      builder: (context, offset, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (offset.dx.abs() < 10) {
              _openExpenseDetail(expense);
            }
          },
          onLongPress: () {
            if (offset.dx.abs() < 10) {
              _openExpenseDetail(expense);
            }
          },
          onHorizontalDragUpdate: (details) {
            final newOffset = Offset(
              (offset.dx + details.delta.dx).clamp(-100.0, 100.0),
              0,
            );
            offsetNotifier.value = newOffset;
          },
          onHorizontalDragEnd: (details) {
            final dx = offsetNotifier.value.dx;
            if (dx < -50) {
              _confirmDeleteExpense(expense).then((_) {
                offsetNotifier.value = Offset.zero;
              });
            } else if (dx > 50) {
              _openExpenseEditor(expense).then((_) {
                offsetNotifier.value = Offset.zero;
              });
            } else {
              offsetNotifier.value = Offset.zero;
            }
          },
          onHorizontalDragCancel: () {
            offsetNotifier.value = Offset.zero;
          },
          child: Stack(
            children: [
              if (offset.dx > 5)
                _buildSwipeBackground(
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  icon: Icons.edit,
                ),
              if (offset.dx < -5)
                _buildSwipeBackground(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  icon: Icons.delete,
                ),
              Transform.translate(
                offset: offset,
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  child: ListTile(
                    leading: Icon(
                      expense.type == ExpenseType.fixed
                          ? Icons.event_repeat
                          : Icons.shopping_bag_outlined,
                      color: Colors.red,
                    ),
                    title: Text(
                      _formatAmount(expense),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_buildSubtitle(expense, account)),
                        if ((expense.description ?? '').isNotEmpty)
                          Text(
                            expense.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(_formatDate(expense.date)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required Alignment alignment,
    required EdgeInsets padding,
    required IconData icon,
  }) {
    return Positioned.fill(
      top: 8,
      bottom: 8,
      child: Align(
        alignment: alignment,
        child: Container(
          width: 100,
          height: double.infinity,
          color: color,
          alignment: alignment,
          padding: padding,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  String _buildSubtitle(Expense expense, PaymentAccount? account) {
    final accountLabel = account?.alias ?? 'Cuenta no encontrada';

    if (expense.type == ExpenseType.sporadic) {
      return '${expense.type.label} - $accountLabel';
    }

    final categoryLabel = expense.fixedCategory?.label ?? 'Sin categoria';
    final frequencyLabel = expense.frequency?.label ?? 'Sin frecuencia';
    return '${expense.type.label} - $categoryLabel - '
        '$frequencyLabel - $accountLabel';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(Expense expense) {
    return '${expense.currency.symbol}${expense.amount.toStringAsFixed(2)}';
  }

  Map<MoneyCurrency, double> _totalsByCurrency(List<Expense> expenses) {
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

  List<Widget> _buildTotalTexts(Map<MoneyCurrency, double> totalsByCurrency) {
    final entries = MoneyCurrency.values
        .where(totalsByCurrency.containsKey)
        .map((currency) => MapEntry(currency, totalsByCurrency[currency]!))
        .toList();

    return [
      for (var index = 0; index < entries.length; index++) ...[
        if (index > 0) const SizedBox(height: 4),
        Text(
          '${entries[index].key.symbol}${entries[index].value.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.white,
            fontSize: index == 0 ? 32 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ];
  }
}
