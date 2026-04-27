import 'package:flutter/material.dart';

import '../data/repository/payment_account_repository.dart';
import '../domain/payment_account_type.dart';

class AddPaymentAccountPage extends StatefulWidget {
  final PaymentAccountRepository repository;

  const AddPaymentAccountPage({super.key, required this.repository});

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = PaymentAccountType.bankAccount;
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.repository.addPaymentAccount(
        bankName: _bankNameController.text.trim(),
        alias: _aliasController.text.trim(),
        type: _selectedType,
        cardLastDigits: _shouldShowCardLastDigits()
            ? (_cardLastDigitsController.text.isNotEmpty
                  ? _cardLastDigitsController.text.trim()
                  : null)
            : null,
        iban: _shouldShowIban()
            ? (_ibanController.text.isNotEmpty
                  ? _ibanController.text.trim()
                  : null)
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta de pago agregada exitosamente')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Cuenta de Pago')),
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
                    setState(() => _selectedType = value);
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
                      : const Text(
                          'Guardar Cuenta',
                          style: TextStyle(fontSize: 16),
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
