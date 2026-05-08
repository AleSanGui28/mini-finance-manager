enum SavingGoalStatus { active, frozen }

extension SavingGoalStatusExtension on SavingGoalStatus {
  String get label {
    switch (this) {
      case SavingGoalStatus.active:
        return 'Activo';
      case SavingGoalStatus.frozen:
        return 'Congelado';
    }
  }
}
