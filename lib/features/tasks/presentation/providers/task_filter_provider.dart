import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/task_entity.dart';

enum TaskFilter { all, pending, completed, overdue, pinned }

class TaskFilterNotifier extends StateNotifier<TaskFilter> {
  TaskFilterNotifier() : super(TaskFilter.all);

  void setFilter(TaskFilter filter) {
    state = filter;
  }
}

final taskFilterProvider =
    StateNotifierProvider<TaskFilterNotifier, TaskFilter>(
      (ref) => TaskFilterNotifier(),
    );

List<TaskEntity> applyTaskFilter(
  List<TaskEntity> tasks,
  TaskFilter filter, {
  required DateTime now,
}) {
  final normalized = tasks.where((task) {
    switch (filter) {
      case TaskFilter.all:
        return true;
      case TaskFilter.pending:
        return task.status != TaskStatus.completed &&
            task.status != TaskStatus.archived;
      case TaskFilter.completed:
        return task.status == TaskStatus.completed;
      case TaskFilter.overdue:
        if (task.status == TaskStatus.completed ||
            task.status == TaskStatus.archived) {
          return false;
        }
        if (task.dueDate == null) {
          return false;
        }
        return task.dueDate!.isBefore(now);
      case TaskFilter.pinned:
        return task.isPinned;
    }
  }).toList();

  if (filter == TaskFilter.all ||
      filter == TaskFilter.pending ||
      filter == TaskFilter.completed) {
    normalized.sort((a, b) {
      if (a.isPinned == b.isPinned) {
        final aDate = a.dueDate ?? DateTime(2100);
        final bDate = b.dueDate ?? DateTime(2100);
        return aDate.compareTo(bDate);
      }
      return a.isPinned ? -1 : 1;
    });
  }

  return normalized;
}
