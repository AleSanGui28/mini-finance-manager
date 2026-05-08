import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../data/repository/payment_account_repository.dart';
import '../data/repository/saving_goal_repository.dart';
import '../domain/payment_account.dart';
import '../domain/saving_goal.dart';
import 'payment_accounts_page.dart';
import 'savings_page.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key, this.repository, this.savingGoalRepository});

  final PaymentAccountRepository? repository;
  final SavingGoalRepository? savingGoalRepository;

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  AppDatabase? _database;
  PaymentAccountRepository? _paymentAccountRepositoryInstance;
  SavingGoalRepository? _savingGoalRepositoryInstance;

  PaymentAccountRepository get _paymentAccountRepository {
    _ensureRepositories();
    return _paymentAccountRepositoryInstance!;
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
    if (_paymentAccountRepositoryInstance != null &&
        _savingGoalRepositoryInstance != null) {
      return;
    }

    final needsDatabase =
        widget.repository == null || widget.savingGoalRepository == null;
    if (needsDatabase && _database == null) {
      _database = AppDatabase();
    }

    _paymentAccountRepositoryInstance ??=
        widget.repository ?? PaymentAccountRepository(_database!);
    _savingGoalRepositoryInstance ??=
        widget.savingGoalRepository ?? SavingGoalRepository(_database!);
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  void _openPaymentAccounts() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PaymentAccountsPage(repository: _paymentAccountRepository),
      ),
    );
  }

  void _openSavings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavingsPage(repository: _savingGoalRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<List<PaymentAccount>>(
            stream: _paymentAccountRepository.watchPaymentAccounts(),
            builder: (context, snapshot) {
              final accounts = snapshot.data ?? [];
              return _buildOptionCard(
                context,
                title: 'Cuentas de pago',
                subtitle: 'Administra cuentas, tarjetas y efectivo',
                footer:
                    '${accounts.length} cuenta${accounts.length == 1 ? '' : 's'}',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.teal,
                onTap: _openPaymentAccounts,
              );
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<SavingGoal>>(
            stream: _savingGoalRepository.watchSavingGoals(),
            builder: (context, snapshot) {
              final savingGoals = snapshot.data ?? [];
              return _buildOptionCard(
                context,
                title: 'Ahorros',
                subtitle: 'Define metas y congela o reanuda objetivos',
                footer:
                    '${savingGoals.length} meta${savingGoals.length == 1 ? '' : 's'}',
                icon: Icons.savings_outlined,
                color: Colors.green,
                onTap: _openSavings,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String footer,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      footer,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
