enum FixedExpenseCategory { services, subscriptions, memberships, other }

extension FixedExpenseCategoryExtension on FixedExpenseCategory {
  String get label {
    switch (this) {
      case FixedExpenseCategory.services:
        return 'Services';
      case FixedExpenseCategory.subscriptions:
        return 'Subscriptions';
      case FixedExpenseCategory.memberships:
        return 'Memberships';
      case FixedExpenseCategory.other:
        return 'Other';
    }
  }
}
