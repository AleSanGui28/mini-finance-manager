enum ExpenseFrequency { weekly, biweekly, monthly, yearly, custom }

extension ExpenseFrequencyExtension on ExpenseFrequency {
  String get label {
    switch (this) {
      case ExpenseFrequency.weekly:
        return 'Weekly';
      case ExpenseFrequency.biweekly:
        return 'Biweekly';
      case ExpenseFrequency.monthly:
        return 'Monthly';
      case ExpenseFrequency.yearly:
        return 'Yearly';
      case ExpenseFrequency.custom:
        return 'Custom';
    }
  }
}
