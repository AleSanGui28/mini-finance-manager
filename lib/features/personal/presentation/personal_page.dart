import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../domain/payment_account.dart';
import '../domain/payment_account_type.dart';
import '../data/repository/payment_account_repository.dart';
import 'add_payment_account_page.dart';

class PersonalPage extends StatefulWidget {
  final PaymentAccountRepository? repository;

  const PersonalPage({super.key, this.repository});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  late final PaymentAccountRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PaymentAccountRepository(AppDatabase());
  }

  void _navigateToAddPaymentAccount() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AddPaymentAccountPage(repository: _repository),
          ),
        )
        .then((_) {
          setState(() {});
        });
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
                        '${account.bankName} · ${account.type.label}',
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
                'Últimos 4 dígitos: ••${account.cardLastDigits}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            if (account.iban != null) ...[
              Text(
                'IBAN: ${'*' * (account.iban!.length - 4)}${account.iban!.substring(account.iban!.length - 4)}',
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
}
