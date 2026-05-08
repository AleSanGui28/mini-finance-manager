import 'package:flutter/material.dart';

import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../../shared/domain/money_currency.dart';
import '../data/repository/expense_repository.dart';
import '../domain/expense.dart';
import '../domain/expense_frequency.dart';
import '../domain/expense_type.dart';
import '../domain/fixed_expense_category.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({
    super.key,
    required this.expenseRepository,
    required this.paymentAccountRepository,
    this.expense,
  });

  final ExpenseRepository expenseRepository;
  final PaymentAccountRepository paymentAccountRepository;
  final Expense? expense;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customFrequencyController = TextEditingController();

  ExpenseType _selectedType = ExpenseType.sporadic;
  MoneyCurrency _selectedCurrency = MoneyCurrency.crc;
  String? _selectedPaymentAccountId;
  DateTime? _selectedDate;
  FixedExpenseCategory? _selectedFixedCategory;
  ExpenseFrequency? _selectedFrequency;
  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    if (expense != null) {
      _amountController.text = expense.amount.toStringAsFixed(2);
      _descriptionController.text = expense.description ?? '';
      _customFrequencyController.text =
          expense.customFrequencyDescription ?? '';
      _selectedType = expense.type;
      _selectedCurrency = expense.currency;
      _selectedPaymentAccountId = expense.paymentAccountId;
      _selectedDate = expense.date;
      _selectedFixedCategory = expense.fixedCategory;
      _selectedFrequency = expense.frequency;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _customFrequencyController.dispose();
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

  Future<void> _saveExpense() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text);
      final description = _emptyToNull(_descriptionController.text);
      final fixedCategory = _selectedType == ExpenseType.fixed
          ? _selectedFixedCategory
          : null;
      final frequency = _selectedType == ExpenseType.fixed
          ? _selectedFrequency
          : null;
      final customFrequencyDescription =
          _selectedType == ExpenseType.fixed &&
              _selectedFrequency == ExpenseFrequency.custom
          ? _emptyToNull(_customFrequencyController.text)
          : null;

      if (_isEditing) {
        final originalExpense = widget.expense!;
        await widget.expenseRepository.updateExpense(
          Expense(
            id: originalExpense.id,
            amount: amount,
            currency: _selectedCurrency,
            type: _selectedType,
            paymentAccountId: _selectedPaymentAccountId!,
            date: _selectedDate!,
            createdAt: originalExpense.createdAt,
            description: description,
            fixedCategory: fixedCategory,
            frequency: frequency,
            customFrequencyDescription: customFrequencyDescription,
          ),
        );
      } else {
        await widget.expenseRepository.addExpense(
          amount: amount,
          currency: _selectedCurrency,
          type: _selectedType,
          paymentAccountId: _selectedPaymentAccountId!,
          date: _selectedDate!,
          description: description,
          fixedCategory: fixedCategory,
          frequency: frequency,
          customFrequencyDescription: customFrequencyDescription,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_successMessage)));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get _successMessage =>
      _isEditing ? 'Gasto actualizado' : 'Gasto registrado';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar gasto' : 'Agregar gasto'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<PaymentAccount>>(
          stream: widget.paymentAccountRepository.watchPaymentAccounts(),
          builder: (context, snapshot) {
            final accounts = snapshot.data ?? [];
            final selectedAccountId =
                accounts.any(
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
                          _isEditing ? 'Editar gasto' : 'Nuevo gasto',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<ExpenseType>(
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            prefixIcon: Icon(Icons.tune),
                            border: OutlineInputBorder(),
                          ),
                          items: ExpenseType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedType = value;
                              if (value == ExpenseType.sporadic) {
                                _selectedFixedCategory = null;
                                _selectedFrequency = null;
                                _customFrequencyController.clear();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
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
                              return 'Ingresa un monto valido';
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
                        DropdownButtonFormField<String>(
                          initialValue: selectedAccountId,
                          decoration: const InputDecoration(
                            labelText: 'Cuenta de pago',
                            prefixIcon: Icon(Icons.account_balance_wallet),
                            border: OutlineInputBorder(),
                          ),
                          items: accounts.map((account) {
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
                              return accounts.isEmpty
                                  ? 'Agrega una cuenta de pago primero'
                                  : 'Selecciona una cuenta de pago';
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
                            labelText: 'Descripcion opcional',
                            prefixIcon: Icon(Icons.notes_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (_selectedType == ExpenseType.fixed) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<FixedExpenseCategory>(
                            initialValue: _selectedFixedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Categoria fija',
                              prefixIcon: Icon(Icons.category_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: FixedExpenseCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFixedCategory = value;
                              });
                            },
                            validator: (value) {
                              if (_selectedType == ExpenseType.fixed &&
                                  value == null) {
                                return 'Selecciona una categoria';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<ExpenseFrequency>(
                            initialValue: _selectedFrequency,
                            decoration: const InputDecoration(
                              labelText: 'Frecuencia',
                              prefixIcon: Icon(Icons.repeat),
                              border: OutlineInputBorder(),
                            ),
                            items: ExpenseFrequency.values.map((frequency) {
                              return DropdownMenuItem(
                                value: frequency,
                                child: Text(frequency.label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFrequency = value;
                                if (value != ExpenseFrequency.custom) {
                                  _customFrequencyController.clear();
                                }
                              });
                            },
                            validator: (value) {
                              if (_selectedType == ExpenseType.fixed &&
                                  value == null) {
                                return 'Selecciona una frecuencia';
                              }

                              return null;
                            },
                          ),
                          if (_selectedFrequency ==
                              ExpenseFrequency.custom) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _customFrequencyController,
                              decoration: const InputDecoration(
                                labelText: 'Descripcion de frecuencia',
                                prefixIcon: Icon(Icons.edit_note),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (_selectedFrequency ==
                                        ExpenseFrequency.custom &&
                                    (value == null || value.trim().isEmpty)) {
                                  return 'Describe la frecuencia';
                                }

                                return null;
                              },
                            ),
                          ],
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _saveExpense,
                            icon: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _isEditing ? 'Guardar cambios' : 'Guardar gasto',
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
