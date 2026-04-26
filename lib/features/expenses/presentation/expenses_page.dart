import 'package:flutter/material.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: const Center(
        child: Text('Aquí se mostrarán los gastos registrados.'),
      ),
    );
  }
}
