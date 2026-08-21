import 'package:flutter/material.dart';

import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../../personal/domain/payment_account_type.dart';
import '../../shared/domain/money_currency.dart';
import '../data/repository/income_repository.dart';
import '../domain/income.dart';
import '../domain/income_category.dart';

class AddIncomePage extends StatefulWidget {
  final IncomeRepository repository;
  final PaymentAccountRepository paymentAccountRepository;
  final Income? income;

  const AddIncomePage({
    super.key,
    required this.repository,
    required this.paymentAccountRepository,
    this.income,
  });

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  MoneyCurrency _selectedCurrency = MoneyCurrency.crc;
  String? _selectedPaymentAccountId;
  IncomeCategory? _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _amountController.text = widget.income!.amount.toStringAsFixed(2);
      _selectedCurrency = widget.income!.currency;
      _selectedPaymentAccountId = widget.income!.paymentAccountId;
      _selectedCategory = widget.income!.category;
      _selectedDate = widget.income!.date;
      _descriptionController.text = widget.income!.description;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _saveIncome() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
      return;
    }

    if (_selectedPaymentAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una cuenta de pago')),
      );
      return;
    }

    try {
      final amount = double.parse(_amountController.text);
      final isEditing = widget.income != null;
      final message = isEditing ? 'Ingreso actualizado' : 'Ingreso registrado';

      if (isEditing) {
        final updatedIncome = Income(
          id: widget.income!.id,
          amount: amount,
          currency: _selectedCurrency,
          paymentAccountId: _selectedPaymentAccountId,
          category: _selectedCategory!,
          date: _selectedDate!,
          description: _descriptionController.text,
          createdAt: widget.income!.createdAt,
        );

        await widget.repository.updateIncome(updatedIncome);
      } else {
        await widget.repository.addIncome(
          amount: amount,
          currency: _selectedCurrency,
          paymentAccountId: _selectedPaymentAccountId!,
          category: _selectedCategory!,
          date: _selectedDate!,
          description: _descriptionController.text,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  List<PaymentAccount> _eligibleIncomeAccounts(List<PaymentAccount> accounts) {
    return accounts.where((account) => account.type.canReceiveIncome).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.income != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar ingreso' : 'Agregar ingreso'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<PaymentAccount>>(
          stream: widget.paymentAccountRepository.watchPaymentAccounts(),
          builder: (context, snapshot) {
            final eligibleAccounts = _eligibleIncomeAccounts(
              snapshot.data ?? [],
            );
            final selectedAccountId =
                eligibleAccounts.any(
                  (account) => account.id == _selectedPaymentAccountId,
                )
                ? _selectedPaymentAccountId
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Editar ingreso' : 'Nuevo ingreso',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Monto',
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');

                            if (amount == null) {
                              return 'Ingresa un monto válido';
                            }

                            if (amount <= 0) {
                              return 'El monto debe ser mayor a 0';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<MoneyCurrency>(
                          initialValue: _selectedCurrency,
                          decoration: const InputDecoration(
                            labelText: 'Moneda',
                            prefixIcon: Icon(Icons.payments_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: MoneyCurrency.values.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(
                                '${currency.symbol} ${currency.label}',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedCurrency = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        if (eligibleAccounts.isEmpty)
                          const _NoEligiblePaymentAccountsMessage()
                        else
                          DropdownButtonFormField<String>(
                            initialValue: selectedAccountId,
                            decoration: const InputDecoration(
                              labelText: 'Cuenta de pago',
                              prefixIcon: Icon(Icons.account_balance_wallet),
                              border: OutlineInputBorder(),
                            ),
                            items: eligibleAccounts.map((account) {
                              return DropdownMenuItem(
                                value: account.id,
                                child: Text(
                                  '${account.alias} - ${account.bankName}',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentAccountId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecciona una cuenta de pago';
                              }

                              return null;
                            },
                          ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<IncomeCategory>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: Icon(Icons.category_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: IncomeCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecciona una categoría';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Selecciona una fecha'
                                  : _formatDate(_selectedDate!),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Descripción opcional',
                            prefixIcon: Icon(Icons.notes_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: eligibleAccounts.isEmpty
                                ? null
                                : _saveIncome,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(
                              isEditing ? 'Guardar cambios' : 'Guardar ingreso',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NoEligiblePaymentAccountsMessage extends StatelessWidget {
  const _NoEligiblePaymentAccountsMessage();

  @override
  Widget build(BuildContext context) {
    return const InputDecorator(
      decoration: InputDecoration(
        labelText: 'Cuenta de pago',
        prefixIcon: Icon(Icons.info_outline),
        border: OutlineInputBorder(),
      ),
      child: Text(
        'Agrega una cuenta bancaria, tarjeta de debito o efectivo para registrar ingresos.',
      ),
    );
  }
}
