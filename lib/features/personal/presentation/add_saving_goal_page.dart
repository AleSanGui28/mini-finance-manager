import 'package:flutter/material.dart';

import '../data/repository/saving_goal_repository.dart';
import '../domain/saving_goal.dart';

class AddSavingGoalPage extends StatefulWidget {
  const AddSavingGoalPage({
    super.key,
    required this.repository,
    this.savingGoal,
  });

  final SavingGoalRepository repository;
  final SavingGoal? savingGoal;

  @override
  State<AddSavingGoalPage> createState() => _AddSavingGoalPageState();
}

class _AddSavingGoalPageState extends State<AddSavingGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();

  DateTime? _selectedTargetDate;
  bool _isSaving = false;

  bool get _isEditing => widget.savingGoal != null;

  @override
  void initState() {
    super.initState();
    final savingGoal = widget.savingGoal;
    if (savingGoal != null) {
      _titleController.text = savingGoal.title;
      _targetAmountController.text = savingGoal.targetAmount.toStringAsFixed(2);
      _selectedTargetDate = savingGoal.targetDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 20),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedTargetDate = pickedDate;
    });
  }

  Future<void> _saveSavingGoal() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);

    try {
      final targetAmount = double.parse(_targetAmountController.text);
      final title = _titleController.text.trim();

      if (_isEditing) {
        final originalGoal = widget.savingGoal!;
        await widget.repository.updateSavingGoal(
          SavingGoal(
            id: originalGoal.id,
            title: title,
            targetAmount: targetAmount,
            targetDate: _selectedTargetDate,
            status: originalGoal.status,
            createdAt: originalGoal.createdAt,
            updatedAt: originalGoal.updatedAt,
          ),
        );
      } else {
        await widget.repository.addSavingGoal(
          title: title,
          targetAmount: targetAmount,
          targetDate: _selectedTargetDate,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Meta de ahorro actualizada' : 'Meta de ahorro creada',
          ),
        ),
      );
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar ahorro' : 'Agregar ahorro'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      _isEditing ? 'Editar meta' : 'Nueva meta',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titulo o descripcion',
                        prefixIcon: Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa un titulo o descripcion';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Monto objetivo',
                        prefixIcon: Icon(Icons.savings_outlined),
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
                    InkWell(
                      onTap: _pickTargetDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha limite opcional',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedTargetDate == null
                              ? 'Sin limite de tiempo'
                              : _formatDate(_selectedTargetDate!),
                        ),
                      ),
                    ),
                    if (_selectedTargetDate != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedTargetDate = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Quitar fecha limite'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveSavingGoal,
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
                          _isEditing ? 'Guardar cambios' : 'Guardar ahorro',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
