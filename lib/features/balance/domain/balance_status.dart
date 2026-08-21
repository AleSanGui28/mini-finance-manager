enum BalanceStatus { surplus, deficit, neutral }

extension BalanceStatusExtension on BalanceStatus {
  String get label {
    switch (this) {
      case BalanceStatus.surplus:
        return 'Beneficio';
      case BalanceStatus.deficit:
        return 'Déficit';
      case BalanceStatus.neutral:
        return 'Balance neutro';
    }
  }
}
