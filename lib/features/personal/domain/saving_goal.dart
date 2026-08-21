import 'saving_goal_status.dart';

class SavingGoal {
  const SavingGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.status,
    required this.createdAt,
    this.targetDate,
    this.updatedAt,
  });

  final String id;
  final String title;
  final double targetAmount;
  final DateTime? targetDate;
  final SavingGoalStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
