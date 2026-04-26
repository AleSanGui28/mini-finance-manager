import 'package:flutter/material.dart';

import '../data/repository/income_repository.dart';
import '../domain/income.dart';
import '../domain/income_category.dart';
import 'add_income_page.dart';

class IncomesPage extends StatefulWidget {
  final IncomeRepository repository;

  const IncomesPage({super.key, required this.repository});

  @override
  State<IncomesPage> createState() => _IncomesPageState();
}

class _IncomesPageState extends State<IncomesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresos'), elevation: 0),
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

          // Calculate total
          final totalAmount = incomes.fold<double>(
            0,
            (sum, income) => sum + income.amount,
          );

          // Sort by date descending
          final sortedIncomes = List<Income>.from(incomes)
            ..sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total de ingresos',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₡${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Income list or empty state
              if (sortedIncomes.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wallet_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay ingresos registrados',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedIncomes.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final income = sortedIncomes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 0,
                        ),
                        child: ListTile(
                          title: Text(
                            '₡${income.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(income.category.label),
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
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => AddIncomePage(repository: widget.repository),
            ),
          );

          if (result == true && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Ingreso guardado')));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar ingreso'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
