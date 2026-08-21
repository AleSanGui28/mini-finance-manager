import 'package:flutter/material.dart';

import '../data/repository/payment_account_repository.dart';
import '../domain/payment_account.dart';
import '../domain/payment_account_type.dart';
import 'credit_card_billing_cycle_text.dart';

class AddPaymentAccountPage extends StatefulWidget {
  final PaymentAccountRepository repository;
  final PaymentAccount? paymentAccount;

  const AddPaymentAccountPage({
    super.key,
    required this.repository,
    this.paymentAccount,
  });

  @override
  State<AddPaymentAccountPage> createState() => _AddPaymentAccountPageState();
}

class _AddPaymentAccountPageState extends State<AddPaymentAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late PaymentAccountType _selectedType;
  final _bankNameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _cardLastDigitsController = TextEditingController();
  final _ibanController = TextEditingController();
  int? _selectedClosingDayOfMonth;
  bool _isLoading = false;

  bool get _isEditing => widget.paymentAccount != null;

  @override
  void initState() {
    super.initState();
    final paymentAccount = widget.paymentAccount;
    _selectedType = paymentAccount?.type ?? PaymentAccountType.bankAccount;
    if (paymentAccount != null) {
      _bankNameController.text = paymentAccount.bankName;
      _aliasController.text = paymentAccount.alias;
      _cardLastDigitsController.text = paymentAccount.cardLastDigits ?? '';
      _ibanController.text = paymentAccount.iban ?? '';
      _selectedClosingDayOfMonth = paymentAccount.closingDayOfMonth;
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _aliasController.dispose();
    _cardLastDigitsController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  bool _shouldShowCardLastDigits() {
    return _selectedType == PaymentAccountType.debitCard ||
        _selectedType == PaymentAccountType.creditCard;
  }

  bool _shouldShowIban() {
    return _selectedType == PaymentAccountType.bankAccount ||
        _selectedType == PaymentAccountType.debitCard ||
        _selectedType == PaymentAccountType.creditCard;
  }

  bool _shouldShowClosingDayOfMonth() {
    return _selectedType == PaymentAccountType.creditCard;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cardLastDigits = _shouldShowCardLastDigits()
          ? _emptyToNull(_cardLastDigitsController.text)
          : null;
      final iban = _shouldShowIban()
          ? _emptyToNull(_ibanController.text)
          : null;
      final closingDayOfMonth = _shouldShowClosingDayOfMonth()
          ? _selectedClosingDayOfMonth
          : null;

      if (_isEditing) {
        final originalAccount = widget.paymentAccount!;
        await widget.repository.updatePaymentAccount(
          PaymentAccount(
            id: originalAccount.id,
            bankName: _bankNameController.text.trim(),
            alias: _aliasController.text.trim(),
            type: _selectedType,
            closingDayOfMonth: closingDayOfMonth,
            cardLastDigits: cardLastDigits,
            iban: iban,
            createdAt: originalAccount.createdAt,
          ),
        );
      } else {
        await widget.repository.addPaymentAccount(
          bankName: _bankNameController.text.trim(),
          alias: _aliasController.text.trim(),
          type: _selectedType,
          closingDayOfMonth: closingDayOfMonth,
          cardLastDigits: cardLastDigits,
          iban: iban,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Cuenta de pago actualizada'
                  : 'Cuenta de pago agregada exitosamente',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Cuenta de Pago' : 'Agregar Cuenta de Pago',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Dropdown
              DropdownButtonFormField<PaymentAccountType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Cuenta *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: PaymentAccountType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      if (!_shouldShowClosingDayOfMonth()) {
                        _selectedClosingDayOfMonth = null;
                      }
                    });
                  }
                },
                validator: (value) => value == null ? 'Tipo requerido' : null,
              ),
              const SizedBox(height: 16),

              // Bank Name Field
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Banco/Entidad *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                  hintText: 'Ej: Banco Nacional',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Banco/Entidad requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Alias Field
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(
                  labelText: 'Alias *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                  hintText: 'Ej: Mi cuenta principal',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alias requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Card Last Digits - Conditionally shown
              if (_shouldShowCardLastDigits()) ...[
                TextFormField(
                  controller: _cardLastDigitsController,
                  decoration: const InputDecoration(
                    labelText: 'Últimos 4 dígitos',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                    hintText: '1234',
                    counterText: '',
                  ),
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 4) {
                        return 'Debe ser exactamente 4 dígitos';
                      }
                      if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
                        return 'Solo se permiten dígitos';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              if (_shouldShowClosingDayOfMonth()) ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedClosingDayOfMonth,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de corte *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  items: List.generate(31, (index) => index + 1).map((day) {
                    return DropdownMenuItem(value: day, child: Text('$day'));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClosingDayOfMonth = value;
                    });
                  },
                  validator: (value) {
                    if (_selectedType == PaymentAccountType.creditCard &&
                        value == null) {
                      return 'Selecciona una fecha de corte';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Rango de pago calculado',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  child: Text(
                    _selectedClosingDayOfMonth == null
                        ? 'Selecciona una fecha de corte'
                        : formatPaymentWindow(_selectedClosingDayOfMonth!),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // IBAN - Conditionally shown
              if (_shouldShowIban()) ...[
                TextFormField(
                  controller: _ibanController,
                  decoration: const InputDecoration(
                    labelText: 'IBAN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    hintText: 'Ej: ES9121000418450200051332',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 15 || value.length > 34) {
                        return 'IBAN debe tener entre 15 y 34 caracteres';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEditing ? 'Guardar Cambios' : 'Guardar Cuenta',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
