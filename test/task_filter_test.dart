import 'package:flutter_test/flutter_test.dart';
import 'package:perductivity/core/database/database.dart';
import 'package:perductivity/features/tasks/domain/entities/task_entity.dart';
import 'package:perductivity/features/tasks/presentation/providers/task_filter_provider.dart';

void main() {
  group('applyTaskFilter', () {
    final now = DateTime(2026, 8, 2, 12);

    final overdueTask = TaskEntity(
      title: 'Overdue task',
      categoryId: 1,
      priority: TaskPriority.high,
      status: TaskStatus.todo,
      dueDate: now.subtract(const Duration(days: 1)),
    );

    final completedTask = TaskEntity(
      title: 'Completed task',
      categoryId: 1,
      priority: TaskPriority.medium,
      status: TaskStatus.completed,
      dueDate: now.add(const Duration(days: 1)),
    );

    final pinnedTask = TaskEntity(
      title: 'Pinned task',
      categoryId: 1,
      priority: TaskPriority.low,
      status: TaskStatus.todo,
      dueDate: now.add(const Duration(days: 2)),
      isPinned: true,
    );

    test('returns overdue tasks for the overdue filter', () {
      final result = applyTaskFilter(
        [overdueTask, completedTask, pinnedTask],
        TaskFilter.overdue,
        now: now,
      );

      expect(result, [overdueTask]);
    });

    test('returns only pinned tasks for the pinned filter', () {
      final result = applyTaskFilter(
        [overdueTask, completedTask, pinnedTask],
        TaskFilter.pinned,
        now: now,
      );

      expect(result, [pinnedTask]);
    });

    test('pending excludes completed and archived tasks', () {
      final archivedTask = TaskEntity(
        title: 'Archived task',
        categoryId: 1,
        priority: TaskPriority.low,
        status: TaskStatus.archived,
      );

      final result = applyTaskFilter(
        [overdueTask, completedTask, archivedTask, pinnedTask],
        TaskFilter.pending,
        now: now,
      );

      expect(result, [pinnedTask, overdueTask]);
    });

    test('a task due now is not overdue', () {
      final result = applyTaskFilter(
        [
          TaskEntity(
            title: 'Due now',
            categoryId: 1,
            priority: TaskPriority.medium,
            status: TaskStatus.todo,
            dueDate: now,
          ),
        ],
        TaskFilter.overdue,
        now: now,
      );

      expect(result, isEmpty);
    });
  });
}
