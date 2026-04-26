import 'package:flutter/material.dart';

import '../data/repository/income_repository.dart';
import '../domain/income.dart';
import '../domain/income_category.dart';

class IncomeListPage extends StatefulWidget {
  final IncomeRepository repository;

  const IncomeListPage({super.key, required this.repository});

  @override
  State<IncomeListPage> createState() => _IncomeListPageState();
}

class _IncomeListPageState extends State<IncomeListPage> {
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

          // Sort by date descending
          incomes.sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: incomes.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final income = incomes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
          );
        },
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
