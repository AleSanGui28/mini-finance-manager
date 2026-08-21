import 'package:flutter/material.dart';

import '../data/repository/payment_account_repository.dart';
import '../domain/payment_account.dart';
import '../domain/payment_account_type.dart';
import 'add_payment_account_page.dart';
import 'credit_card_billing_cycle_text.dart';
import 'payment_account_detail_page.dart';

class PaymentAccountsPage extends StatefulWidget {
  const PaymentAccountsPage({super.key, required this.repository});

  final PaymentAccountRepository repository;

  @override
  State<PaymentAccountsPage> createState() => _PaymentAccountsPageState();
}

class _PaymentAccountsPageState extends State<PaymentAccountsPage> {
  final Map<String, ValueNotifier<Offset>> _slideOffsets = {};

  PaymentAccountRepository get _repository => widget.repository;

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

  void _navigateToAddPaymentAccount() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AddPaymentAccountPage(repository: _repository),
          ),
        )
        .then((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  Future<void> _openPaymentAccountEditor(PaymentAccount account) {
    _getOffsetNotifier(account.id).value = Offset.zero;
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddPaymentAccountPage(
          repository: _repository,
          paymentAccount: account,
        ),
      ),
    );
  }

  void _openPaymentAccountDetail(PaymentAccount account) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PaymentAccountDetailPage(
              repository: _repository,
              paymentAccount: account,
            ),
          ),
        )
        .then((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  Future<bool> _confirmDeletePaymentAccount(PaymentAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('Seguro que deseas eliminar esta cuenta de pago?'),
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
      await _repository.deletePaymentAccount(account.id);

      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cuenta de pago eliminada')));
      return true;
    } on PaymentAccountDeleteBlockedException catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return false;
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
      appBar: AppBar(title: const Text('Cuentas de Pago')),
      body: StreamBuilder<List<PaymentAccount>>(
        stream: _repository.watchPaymentAccounts(),
        builder: (context, snapshot) {
          final accounts = snapshot.data ?? [];

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin cuentas registradas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega una cuenta de pago para comenzar',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return _buildAccountCard(context, account);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPaymentAccount,
        tooltip: 'Agregar cuenta de pago',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, PaymentAccount account) {
    final offsetNotifier = _getOffsetNotifier(account.id);

    return ValueListenableBuilder<Offset>(
      valueListenable: offsetNotifier,
      builder: (context, offset, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (offset.dx.abs() < 10) {
              _openPaymentAccountDetail(account);
            }
          },
          onLongPress: () {
            if (offset.dx.abs() < 10) {
              _openPaymentAccountDetail(account);
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
              _confirmDeletePaymentAccount(account).then((_) {
                offsetNotifier.value = Offset.zero;
              });
            } else if (dx > 50) {
              _openPaymentAccountEditor(account).then((_) {
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
                child: _buildAccountCardContent(context, account),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountCardContent(
    BuildContext context,
    PaymentAccount account,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getAccountIcon(account.type),
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.alias,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${account.bankName} - ${account.type.label}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (account.cardLastDigits != null) ...[
              Text(
                'Ultimos 4 digitos: **** ${account.cardLastDigits}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            if (account.iban != null) ...[
              Text(
                'IBAN: ${_maskedIban(account.iban!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            if (account.type == PaymentAccountType.creditCard &&
                account.closingDayOfMonth != null) ...[
              Text(
                formatClosingDayOfMonth(account.closingDayOfMonth!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                formatPaymentWindow(account.closingDayOfMonth!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Creada: ${_formatDate(account.createdAt)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required Alignment alignment,
    required EdgeInsets padding,
    required IconData icon,
  }) {
    return Positioned.fill(
      bottom: 12,
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

  IconData _getAccountIcon(PaymentAccountType type) {
    switch (type) {
      case PaymentAccountType.bankAccount:
        return Icons.account_balance;
      case PaymentAccountType.debitCard:
        return Icons.credit_card;
      case PaymentAccountType.creditCard:
        return Icons.credit_card;
      case PaymentAccountType.cash:
        return Icons.payments;
      case PaymentAccountType.other:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _maskedIban(String iban) {
    if (iban.length <= 4) {
      return iban;
    }

    return '${''.padLeft(iban.length - 4, '*')}${iban.substring(iban.length - 4)}';
  }
}
