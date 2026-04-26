enum IncomeCategory { salary, sinpe, transaction, other }

extension IncomeCategoryExtension on IncomeCategory {
  String get label {
    switch (this) {
      case IncomeCategory.salary:
        return 'Salary';
      case IncomeCategory.sinpe:
        return 'SINPE';
      case IncomeCategory.transaction:
        return 'Transaction';
      case IncomeCategory.other:
        return 'Other';
    }
  }
}
