import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_providers.dart';

class TaskListNotifier extends StateNotifier<AsyncValue<List<TaskEntity>>> {
  final TaskRepository _repository;

  TaskListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTask({
    required String title,
    String? description,
    required int categoryId,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    try {
      await _repository.createTask(
        TaskEntity(
          title: title,
          description: description,
          categoryId: categoryId,
          priority: priority,
          status: TaskStatus.todo,
          dueDate: dueDate,
        ),
      );
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask({
    required int id,
    required String title,
    String? description,
    required int categoryId,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
  }) async {
    try {
      await _repository.updateTask(
        id,
        TaskEntity(
          title: title,
          description: description,
          categoryId: categoryId,
          priority: priority,
          status: status,
          dueDate: dueDate,
        ),
      );
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeTask(int id) async {
    try {
      await _repository.completeTask(id);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uncompleteTask(int id) async {
    try {
      await _repository.uncompleteTask(id);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> archiveTask(int id) async {
    try {
      await _repository.archiveTask(id);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> togglePin(int id, bool isPinned) async {
    try {
      await _repository.togglePin(id, isPinned);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, AsyncValue<List<TaskEntity>>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskListNotifier(repository);
});
