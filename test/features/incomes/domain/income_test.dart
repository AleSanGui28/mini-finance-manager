import 'package:flutter_test/flutter_test.dart';
import 'package:mini_finance_manager/features/incomes/domain/income.dart';
import 'package:mini_finance_manager/features/incomes/domain/income_category.dart';

void main() {
  group('Income', () {
    test('creates income with all required fields', () {
      // Arrange
      const id = 'income-1';
      const amount = 1500.0;
      final category = IncomeCategory.salary;
      final date = DateTime(2026, 4, 23);
      final createdAt = DateTime(2026, 4, 23, 10, 30);
      const description = 'Monthly salary';

      // Act
      final income = Income(
        id: id,
        amount: amount,
        category: category,
        date: date,
        createdAt: createdAt,
        description: description,
      );

      // Assert
      expect(income.id, equals(id));
      expect(income.amount, equals(amount));
      expect(income.category, equals(category));
      expect(income.date, equals(date));
      expect(income.createdAt, equals(createdAt));
      expect(income.description, equals(description));
    });

    test('creates income with zero amount (edge case)', () {
      final income = Income(
        id: 'id',
        amount: 0,
        category: IncomeCategory.salary,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        description: '',
      );

      expect(income.amount, equals(0));
    });

    test('creates income with large amount', () {
      final income = Income(
        id: 'id',
        amount: 999999.99,
        category: IncomeCategory.salary,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        description: '',
      );

      expect(income.amount, equals(999999.99));
    });

    test('creates income with empty description', () {
      final income = Income(
        id: 'id',
        amount: 500,
        category: IncomeCategory.other,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        description: '',
      );

      expect(income.description, isEmpty);
    });

    test('creates income with all category types', () {
      final categories = [
        IncomeCategory.salary,
        IncomeCategory.sinpe,
        IncomeCategory.transaction,
        IncomeCategory.other,
      ];

      for (final category in categories) {
        final income = Income(
          id: 'id',
          amount: 100,
          category: category,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          description: '',
        );

        expect(income.category, equals(category));
      }
    });
  });

  group('IncomeCategory Extension', () {
    test('salary has correct label', () {
      expect(IncomeCategory.salary.label, equals('Salary'));
    });

    test('sinpe has correct label', () {
      expect(IncomeCategory.sinpe.label, equals('SINPE'));
    });

    test('transaction has correct label', () {
      expect(IncomeCategory.transaction.label, equals('Transaction'));
    });

    test('other has correct label', () {
      expect(IncomeCategory.other.label, equals('Other'));
    });

    test('all categories have non-empty labels', () {
      for (final category in IncomeCategory.values) {
        expect(category.label, isNotEmpty);
      }
    });

    test('all categories have unique labels', () {
      final labels = IncomeCategory.values.map((c) => c.label).toList();
      final uniqueLabels = labels.toSet();

      expect(labels.length, equals(uniqueLabels.length));
    });
  });
}
