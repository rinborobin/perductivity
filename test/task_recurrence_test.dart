import 'package:flutter_test/flutter_test.dart';
import 'package:perductivity/core/database/database.dart';
import 'package:perductivity/features/tasks/data/datasource/task_datasource.dart';

void main() {
  group('nextRecurringDueDate', () {
    test('advances daily recurrence by one day', () {
      final result = nextRecurringDueDate(
        DateTime(2026, 8, 22, 9, 30),
        TaskRecurrence.daily,
      );

      expect(result, DateTime(2026, 8, 23, 9, 30));
    });

    test('clamps monthly recurrence to the last day of the month', () {
      final result = nextRecurringDueDate(
        DateTime(2026, 1, 31, 9, 30),
        TaskRecurrence.monthly,
      );

      expect(result, DateTime(2026, 2, 28, 9, 30));
    });
  });
}
