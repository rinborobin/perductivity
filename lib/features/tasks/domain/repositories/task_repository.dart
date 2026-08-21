import '../../../../core/database/database.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks();
  Future<List<TaskEntity>> getTasksByStatus(TaskStatus status);
  Future<List<TaskEntity>> getTasksByCategory(int categoryId);
  Future<List<TaskEntity>> getTasksDueToday();
  Future<List<TaskEntity>> getUpcomingTasks({int limit = 10});
  Future<List<TaskEntity>> searchTasks(String query);
  Future<TaskEntity?> getTaskById(int id);
  Future<int> createTask(TaskEntity task);
  Future<bool> updateTask(int id, TaskEntity task);
  Future<bool> completeTask(int id);
  Future<bool> uncompleteTask(int id);
  Future<bool> archiveTask(int id);
  Future<bool> togglePin(int id, bool isPinned);
  Future<bool> deleteTask(int id);
  Stream<List<TaskEntity>> watchAllTasks();
  Stream<List<TaskEntity>> watchTasksByStatus(TaskStatus status);
  Future<Map<TaskStatus, int>> getTaskCounts();
}
