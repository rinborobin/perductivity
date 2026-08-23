import '../../../../core/database/database.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/subtask_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasource/task_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final models = await _dataSource.getAllTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByStatus(TaskStatus status) async {
    final models = await _dataSource.getTasksByStatus(status);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByCategory(int categoryId) async {
    final models = await _dataSource.getTasksByCategory(categoryId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksDueToday() async {
    final models = await _dataSource.getTasksDueToday();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getUpcomingTasks({int limit = 10}) async {
    final models = await _dataSource.getUpcomingTasks(limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> searchTasks(String query) async {
    final models = await _dataSource.searchTasks(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(int id) async {
    final model = await _dataSource.getTaskById(id);
    return model?.toEntity();
  }

  @override
  Future<int> createTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    return await _dataSource.createTask(model);
  }

  @override
  Future<bool> updateTask(int id, TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    return await _dataSource.updateTask(id, model);
  }

  @override
  Future<bool> completeTask(int id) async {
    return await _dataSource.completeTask(id);
  }

  @override
  Future<bool> uncompleteTask(int id) async {
    return await _dataSource.uncompleteTask(id);
  }

  @override
  Future<bool> archiveTask(int id) async {
    return await _dataSource.archiveTask(id);
  }

  @override
  Future<bool> togglePin(int id, bool isPinned) async {
    return await _dataSource.togglePin(id, isPinned);
  }

  @override
  Future<bool> deleteTask(int id) async {
    return await _dataSource.deleteTask(id);
  }

  @override
  Future<List<SubtaskEntity>> getSubtasks(int taskId) async {
    final models = await _dataSource.getSubtasks(taskId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> createSubtask(SubtaskEntity subtask) async {
    return await _dataSource.createSubtask(subtask);
  }

  @override
  Future<bool> toggleSubtask(int id, bool isCompleted) async {
    return await _dataSource.toggleSubtask(id, isCompleted);
  }

  @override
  Future<bool> deleteSubtask(int id) async {
    return await _dataSource.deleteSubtask(id);
  }

  @override
  Stream<List<TaskEntity>> watchAllTasks() {
    return _dataSource.watchAllTasks().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Stream<List<TaskEntity>> watchTasksByStatus(TaskStatus status) {
    return _dataSource
        .watchTasksByStatus(status)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Map<TaskStatus, int>> getTaskCounts() async {
    return await _dataSource.getTaskCounts();
  }
}
