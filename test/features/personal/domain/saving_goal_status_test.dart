import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/personal/domain/saving_goal_status.dart';

void main() {
  group('SavingGoalStatus labels', () {
    test('returns Spanish labels for saving goal statuses', () {
      expect(SavingGoalStatus.active.label, 'Activo');
      expect(SavingGoalStatus.frozen.label, 'Congelado');
    });
  });
}
