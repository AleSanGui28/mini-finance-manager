import 'package:flutter/material.dart';

import '../data/repository/saving_goal_repository.dart';
import '../domain/saving_goal.dart';
import '../domain/saving_goal_status.dart';
import 'add_saving_goal_page.dart';

class SavingGoalDetailPage extends StatefulWidget {
  const SavingGoalDetailPage({
    super.key,
    required this.repository,
    required this.savingGoal,
  });

  final SavingGoalRepository repository;
  final SavingGoal savingGoal;

  @override
  State<SavingGoalDetailPage> createState() => _SavingGoalDetailPageState();
}

class _SavingGoalDetailPageState extends State<SavingGoalDetailPage> {
  late SavingGoal _savingGoal;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _savingGoal = widget.savingGoal;
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ahorro'),
        content: const Text('Seguro que deseas eliminar esta meta de ahorro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.repository.deleteSavingGoal(_savingGoal.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meta de ahorro eliminada')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  Future<void> _toggleStatus() async {
    setState(() => _isUpdatingStatus = true);

    try {
      final now = DateTime.now();
      if (_savingGoal.status == SavingGoalStatus.active) {
        await widget.repository.freezeSavingGoal(_savingGoal.id);
        _savingGoal = SavingGoal(
          id: _savingGoal.id,
          title: _savingGoal.title,
          targetAmount: _savingGoal.targetAmount,
          targetDate: _savingGoal.targetDate,
          status: SavingGoalStatus.frozen,
          createdAt: _savingGoal.createdAt,
          updatedAt: now,
        );
      } else {
        await widget.repository.resumeSavingGoal(_savingGoal.id);
        _savingGoal = SavingGoal(
          id: _savingGoal.id,
          title: _savingGoal.title,
          targetAmount: _savingGoal.targetAmount,
          targetDate: _savingGoal.targetDate,
          status: SavingGoalStatus.active,
          createdAt: _savingGoal.createdAt,
          updatedAt: now,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _savingGoal.status == SavingGoalStatus.frozen
                ? 'Meta congelada'
                : 'Meta reanudada',
          ),
        ),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  Future<void> _openEditor() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddSavingGoalPage(
          repository: widget.repository,
          savingGoal: _savingGoal,
        ),
      ),
    );

    if (updated == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _savingGoal.status == SavingGoalStatus.active
        ? Colors.green
        : Colors.blueGrey;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del ahorro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.savings_outlined,
                            size: 40,
                            color: statusColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _savingGoal.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildStatusChip(statusColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Monto objetivo',
                        _formatAmount(_savingGoal.targetAmount),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Fecha limite',
                        _savingGoal.targetDate == null
                            ? 'Sin limite de tiempo'
                            : _formatDate(_savingGoal.targetDate!),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Creada',
                        _formatDate(_savingGoal.createdAt),
                      ),
                      if (_savingGoal.updatedAt != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Actualizada',
                          _formatDate(_savingGoal.updatedAt!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isUpdatingStatus ? null : _toggleStatus,
                  icon: _isUpdatingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _savingGoal.status == SavingGoalStatus.active
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                        ),
                  label: Text(
                    _savingGoal.status == SavingGoalStatus.active
                        ? 'Congelar'
                        : 'Reanudar',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openEditor,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleDelete,
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _savingGoal.status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  String _formatAmount(double amount) => amount.toStringAsFixed(2);

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
