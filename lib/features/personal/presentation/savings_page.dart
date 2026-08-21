import 'package:flutter/material.dart';

import '../data/repository/saving_goal_repository.dart';
import '../domain/saving_goal.dart';
import '../domain/saving_goal_status.dart';
import 'add_saving_goal_page.dart';
import 'saving_goal_detail_page.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key, required this.repository});

  final SavingGoalRepository repository;

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final Map<String, ValueNotifier<Offset>> _slideOffsets = {};

  ValueNotifier<Offset> _getOffsetNotifier(String id) {
    return _slideOffsets.putIfAbsent(id, () => ValueNotifier(Offset.zero));
  }

  @override
  void dispose() {
    for (final notifier in _slideOffsets.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _openSavingGoalDetail(SavingGoal savingGoal) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavingGoalDetailPage(
          repository: widget.repository,
          savingGoal: savingGoal,
        ),
      ),
    );
  }

  Future<void> _openSavingGoalEditor(SavingGoal savingGoal) {
    _getOffsetNotifier(savingGoal.id).value = Offset.zero;
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddSavingGoalPage(
          repository: widget.repository,
          savingGoal: savingGoal,
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteSavingGoal(SavingGoal savingGoal) async {
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

    if (confirmed != true) return false;

    try {
      await widget.repository.deleteSavingGoal(savingGoal.id);

      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meta de ahorro eliminada')));
      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ahorros'), elevation: 0),
      body: StreamBuilder<List<SavingGoal>>(
        stream: widget.repository.watchSavingGoals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final savingGoals = snapshot.data ?? [];

          return Column(
            children: [
              _buildSummary(savingGoals),
              if (savingGoals.isEmpty)
                _buildEmptyState()
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: savingGoals.length,
                    itemBuilder: (context, index) {
                      return _buildSavingGoalRow(context, savingGoals[index]);
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddSavingGoalPage(repository: widget.repository),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar ahorro'),
      ),
    );
  }

  Widget _buildSummary(List<SavingGoal> savingGoals) {
    final totalTargetAmount = savingGoals.fold<double>(
      0,
      (total, savingGoal) => total + savingGoal.targetAmount,
    );
    final activeCount = savingGoals
        .where((goal) => goal.status == SavingGoalStatus.active)
        .length;
    final frozenCount = savingGoals.length - activeCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meta total',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(totalTargetAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$activeCount activa${activeCount == 1 ? '' : 's'}'
            ' - $frozenCount congelada${frozenCount == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 64,
              color: Colors.green.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay metas de ahorro',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Agrega una meta para comenzar'),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingGoalRow(BuildContext context, SavingGoal savingGoal) {
    final offsetNotifier = _getOffsetNotifier(savingGoal.id);

    return ValueListenableBuilder<Offset>(
      valueListenable: offsetNotifier,
      builder: (context, offset, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (offset.dx.abs() < 10) {
              _openSavingGoalDetail(savingGoal);
            }
          },
          onLongPress: () {
            if (offset.dx.abs() < 10) {
              _openSavingGoalDetail(savingGoal);
            }
          },
          onHorizontalDragUpdate: (details) {
            final newOffset = Offset(
              (offset.dx + details.delta.dx).clamp(-100.0, 100.0),
              0,
            );
            offsetNotifier.value = newOffset;
          },
          onHorizontalDragEnd: (details) {
            final dx = offsetNotifier.value.dx;
            if (dx < -50) {
              _confirmDeleteSavingGoal(savingGoal).then((_) {
                offsetNotifier.value = Offset.zero;
              });
            } else if (dx > 50) {
              _openSavingGoalEditor(savingGoal).then((_) {
                offsetNotifier.value = Offset.zero;
              });
            } else {
              offsetNotifier.value = Offset.zero;
            }
          },
          onHorizontalDragCancel: () {
            offsetNotifier.value = Offset.zero;
          },
          child: Stack(
            children: [
              if (offset.dx > 5)
                _buildSwipeBackground(
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  icon: Icons.edit,
                ),
              if (offset.dx < -5)
                _buildSwipeBackground(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  icon: Icons.delete,
                ),
              Transform.translate(
                offset: offset,
                child: _buildSavingGoalCard(context, savingGoal),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavingGoalCard(BuildContext context, SavingGoal savingGoal) {
    final statusColor = savingGoal.status == SavingGoalStatus.active
        ? Colors.green
        : Colors.blueGrey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        leading: Icon(Icons.savings_outlined, color: statusColor),
        title: Text(
          savingGoal.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Objetivo: ${_formatAmount(savingGoal.targetAmount)}'),
            Text(
              savingGoal.targetDate == null
                  ? 'Sin limite de tiempo'
                  : 'Fecha limite: ${_formatDate(savingGoal.targetDate!)}',
            ),
            Text(savingGoal.status.label),
          ],
        ),
        trailing: _buildStatusIndicator(statusColor),
      ),
    );
  }

  Widget _buildStatusIndicator(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required Alignment alignment,
    required EdgeInsets padding,
    required IconData icon,
  }) {
    return Positioned.fill(
      top: 8,
      bottom: 8,
      child: Align(
        alignment: alignment,
        child: Container(
          width: 100,
          height: double.infinity,
          color: color,
          alignment: alignment,
          padding: padding,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  String _formatAmount(double amount) => amount.toStringAsFixed(2);

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
