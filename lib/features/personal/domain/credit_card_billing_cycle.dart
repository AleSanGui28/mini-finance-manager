class CreditCardBillingCycle {
  const CreditCardBillingCycle({required this.closingDayOfMonth});

  static const int paymentWindowLengthInDays = 15;
  static const int displayCycleLengthInDays = 30;

  final int closingDayOfMonth;

  int get paymentStartDay => closingDayOfMonth;

  int get paymentEndDay {
    final endDay = closingDayOfMonth + paymentWindowLengthInDays;
    if (endDay <= displayCycleLengthInDays) {
      return endDay;
    }

    return endDay - displayCycleLengthInDays;
  }

  bool get rollsToNextMonth {
    return closingDayOfMonth + paymentWindowLengthInDays >
        displayCycleLengthInDays;
  }

  static bool isValidClosingDayOfMonth(int? day) {
    return day != null && day >= 1 && day <= 31;
  }
}
