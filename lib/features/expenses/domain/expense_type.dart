enum ExpenseType { fixed, sporadic }

extension ExpenseTypeExtension on ExpenseType {
  String get label {
    switch (this) {
      case ExpenseType.fixed:
        return 'Fixed';
      case ExpenseType.sporadic:
        return 'Sporadic';
    }
  }
}
