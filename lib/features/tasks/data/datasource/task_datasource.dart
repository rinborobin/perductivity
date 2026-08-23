import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/subtask_entity.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';

class TaskDataSource {
  final AppDatabase _db;

  TaskDataSource(this._db);

  Future<List<TaskModel>> getAllTasks() async {
    final result = await _db.select(_db.tasks).get();
    return result.map((e) => TaskModel.fromDrift(e)).toList();
  }

  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    final result = await (_db.select(
      _db.tasks,
    )..where((t) => t.status.equals(status.name))).get();
    return result.map((e) => TaskModel.fromDrift(e)).toList();
  }

  Future<List<TaskModel>> getTasksByCategory(int categoryId) async {
    final result = await (_db.select(
      _db.tasks,
    )..where((t) => t.categoryId.equals(categoryId))).get();
    return result.map((e) => TaskModel.fromDrift(e)).toList();
  }

  Future<List<TaskModel>> getTasksDueToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result =
        await (_db.select(_db.tasks)..where(
              (t) =>
                  t.dueDate.isBiggerOrEqualValue(startOfDay) &
                  t.dueDate.isSmallerThanValue(endOfDay),
            ))
            .get();
    return result.map((e) => TaskModel.fromDrift(e)).toList();
  }

  Future<List<TaskModel>> getUpcomingTasks({int limit = 10}) async {
    final now = DateTime.now();
    final result =
        await (_db.select(_db.tasks)
              ..where(
                (t) =>
                    t.dueDate.isBiggerOrEqualValue(now) &
                    t.status.equals(TaskStatus.completed.name).not(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.dueDate)])
              ..limit(limit))
            .get();
    return result.map((e) => TaskModel.fromDrift(e)).toList();
  }

  Future<List<TaskModel>> searchTasks(String query) async {
    final result =
        await (_db.select(_db.tasks)..where(
              (t) =>
                  t.title.like('%$query%') | (t.description.like('%$query%')),
            ))
            .get();
    return result.map((e) => TaskModel.fromDrift(e)).toList();
  }

  Future<TaskModel?> getTaskById(int id) async {
    final result = await (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return result != null ? TaskModel.fromDrift(result) : null;
  }

  Future<int> createTask(TaskModel task) async {
    return await _db.into(_db.tasks).insert(task.toCompanion());
  }

  Future<bool> updateTask(int id, TaskModel task) async {
    final rowsAffected =
        await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            title: Value(task.title),
            description: Value(task.description),
            categoryId: Value(task.categoryId),
            priority: Value(task.priority),
            status: Value(task.status),
            dueDate: Value(task.dueDate),
            completedAt: Value(task.completedAt),
            isPinned: Value(task.isPinned),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  Future<bool> completeTask(int id) async {
    return await _db.transaction(() async {
      final task = await getTaskById(id);
      if (task == null) return false;

      final now = DateTime.now();
      final rowsAffected =
          await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
            TasksCompanion(
              status: const Value(TaskStatus.completed),
              completedAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      if (rowsAffected > 0 &&
          task.recurrence != TaskRecurrence.none &&
          task.dueDate != null) {
        await _db
            .into(_db.tasks)
            .insert(
              TasksCompanion.insert(
                title: task.title,
                description: Value(task.description),
                categoryId: task.categoryId,
                priority: task.priority,
                status: TaskStatus.todo,
                dueDate: Value(
                  nextRecurringDueDate(task.dueDate!, task.recurrence),
                ),
                recurrence: Value(task.recurrence.name),
                isPinned: Value(task.isPinned),
              ),
            );
      }

      return rowsAffected > 0;
    });
  }

  Future<bool> uncompleteTask(int id) async {
    final rowsAffected =
        await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            status: const Value(TaskStatus.todo),
            completedAt: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  Future<bool> archiveTask(int id) async {
    final rowsAffected =
        await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            status: const Value(TaskStatus.archived),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  Future<bool> togglePin(int id, bool isPinned) async {
    final rowsAffected =
        await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            isPinned: Value(isPinned),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  Future<bool> deleteTask(int id) async {
    final rowsAffected = await (_db.delete(
      _db.tasks,
    )..where((t) => t.id.equals(id))).go();
    return rowsAffected > 0;
  }

  Future<List<SubtaskModel>> getSubtasks(int taskId) async {
    final result =
        await (_db.select(_db.subtasks)
              ..where((subtask) => subtask.taskId.equals(taskId))
              ..orderBy([(subtask) => OrderingTerm.asc(subtask.createdAt)]))
            .get();
    return result.map(SubtaskModel.fromDrift).toList();
  }

  Future<int> createSubtask(SubtaskEntity subtask) async {
    return await _db
        .into(_db.subtasks)
        .insert(SubtaskModel.fromEntity(subtask).toCompanion());
  }

  Future<bool> toggleSubtask(int id, bool isCompleted) async {
    final rowsAffected =
        await (_db.update(
          _db.subtasks,
        )..where((subtask) => subtask.id.equals(id))).write(
          SubtasksCompanion(
            isCompleted: Value(isCompleted),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  Future<bool> deleteSubtask(int id) async {
    final rowsAffected = await (_db.delete(
      _db.subtasks,
    )..where((subtask) => subtask.id.equals(id))).go();
    return rowsAffected > 0;
  }

  Stream<List<TaskModel>> watchAllTasks() {
    return _db
        .select(_db.tasks)
        .watch()
        .map((result) => result.map((e) => TaskModel.fromDrift(e)).toList());
  }

  Stream<List<TaskModel>> watchTasksByStatus(TaskStatus status) {
    return (_db.select(_db.tasks)..where((t) => t.status.equals(status.name)))
        .watch()
        .map((result) => result.map((e) => TaskModel.fromDrift(e)).toList());
  }

  Future<int> getTaskCountByStatus(TaskStatus status) async {
    final query = _db.selectOnly(_db.tasks)
      ..addColumns([_db.tasks.id.count()])
      ..where(_db.tasks.status.equals(status.name));
    final result = await query.getSingle();
    return result.read(_db.tasks.id.count()) ?? 0;
  }

  Future<Map<TaskStatus, int>> getTaskCounts() async {
    final counts = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      counts[status] = await getTaskCountByStatus(status);
    }
    return counts;
  }
}

DateTime nextRecurringDueDate(DateTime dueDate, TaskRecurrence recurrence) {
  switch (recurrence) {
    case TaskRecurrence.none:
      return dueDate;
    case TaskRecurrence.daily:
      return dueDate.add(const Duration(days: 1));
    case TaskRecurrence.weekly:
      return dueDate.add(const Duration(days: 7));
    case TaskRecurrence.monthly:
      final nextMonth = DateTime(dueDate.year, dueDate.month + 1, 1);
      final lastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
      return DateTime(
        nextMonth.year,
        nextMonth.month,
        dueDate.day > lastDay ? lastDay : dueDate.day,
        dueDate.hour,
        dueDate.minute,
      );
  }
}
