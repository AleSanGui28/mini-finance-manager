import 'package:flutter/material.dart';

import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../../shared/domain/money_currency.dart';
import '../data/repository/income_repository.dart';
import '../domain/income.dart';
import '../domain/income_category.dart';
import 'add_income_page.dart';
import 'income_detail_page.dart';

class IncomeListPage extends StatefulWidget {
  final IncomeRepository repository;
  final PaymentAccountRepository paymentAccountRepository;

  const IncomeListPage({
    super.key,
    required this.repository,
    required this.paymentAccountRepository,
  });

  @override
  State<IncomeListPage> createState() => _IncomeListPageState();
}

class _IncomeListPageState extends State<IncomeListPage> {
  final Map<String, ValueNotifier<Offset>> _slideOffsets = {};

  ValueNotifier<Offset> _getOffsetNotifier(String id) {
    return _slideOffsets.putIfAbsent(id, () => ValueNotifier(Offset.zero));
  }

  @override
  void dispose() {
    for (var notifier in _slideOffsets.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _openIncomeDetail(Income income) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IncomeDetailPage(
          repository: widget.repository,
          paymentAccountRepository: widget.paymentAccountRepository,
          income: income,
        ),
      ),
    );
  }

  Future<void> _openIncomeEditor(Income income) async {
    _getOffsetNotifier(income.id).value = Offset.zero;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddIncomePage(
          repository: widget.repository,
          paymentAccountRepository: widget.paymentAccountRepository,
          income: income,
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteIncome(Income income) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: const Text('Seguro que deseas eliminar este ingreso?'),
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
      await widget.repository.deleteIncome(income.id);

      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingreso eliminado')));
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
      appBar: AppBar(title: const Text('Historial de ingresos')),
      body: StreamBuilder<List<Income>>(
        stream: widget.repository.watchIncomes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final incomes = snapshot.data ?? [];

          if (incomes.isEmpty) {
            return const Center(child: Text('No hay ingresos registrados'));
          }

          final sortedIncomes = List<Income>.from(incomes)
            ..sort((a, b) => b.date.compareTo(a.date));

          return StreamBuilder<List<PaymentAccount>>(
            stream: widget.paymentAccountRepository.watchPaymentAccounts(),
            builder: (context, accountSnapshot) {
              final accountsById = {
                for (final account in accountSnapshot.data ?? [])
                  account.id: account,
              };

              return ListView.builder(
                itemCount: sortedIncomes.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final income = sortedIncomes[index];
                  final account = income.paymentAccountId == null
                      ? null
                      : accountsById[income.paymentAccountId];

                  return _buildIncomeRow(context, income, account);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildIncomeRow(
    BuildContext context,
    Income income,
    PaymentAccount? account,
  ) {
    final offsetNotifier = _getOffsetNotifier(income.id);

    return ValueListenableBuilder<Offset>(
      valueListenable: offsetNotifier,
      builder: (context, offset, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (offset.dx.abs() < 10) {
              _openIncomeDetail(income);
            }
          },
          onLongPress: () {
            if (offset.dx.abs() < 10) {
              _openIncomeDetail(income);
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
              _confirmDeleteIncome(income).then((confirmed) {
                offsetNotifier.value = Offset.zero;
              });
            } else if (dx > 50) {
              _openIncomeEditor(income);
            } else {
              offsetNotifier.value = Offset.zero;
            }
          },
          onHorizontalDragCancel: () {
            offsetNotifier.value = Offset.zero;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: Text(
                          _formatAmount(income),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_buildSubtitle(income, account)),
                            if (income.description.isNotEmpty)
                              Text(
                                income.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(_formatDate(income.date)),
                          ],
                        ),
                        leading: Icon(
                          _getCategoryIcon(income.category),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  String _buildSubtitle(Income income, PaymentAccount? account) {
    final accountLabel = _accountLabel(income, account);
    return '${income.category.label} - $accountLabel';
  }

  String _accountLabel(Income income, PaymentAccount? account) {
    if (income.paymentAccountId == null) {
      return 'Sin cuenta asignada';
    }

    return account?.alias ?? 'Cuenta no encontrada';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(Income income) {
    return '${income.currency.symbol}${income.amount.toStringAsFixed(2)}';
  }

  IconData _getCategoryIcon(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return Icons.card_giftcard;
      case IncomeCategory.sinpe:
        return Icons.payment;
      case IncomeCategory.transaction:
        return Icons.swap_horiz;
      case IncomeCategory.other:
        return Icons.help_outline;
    }
  }
}
