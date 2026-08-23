import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final int categoryId;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final TaskRecurrence recurrence;
  final bool isPinned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.priority,
    required this.status,
    this.dueDate,
    this.completedAt,
    this.recurrence = TaskRecurrence.none,
    this.isPinned = false,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      categoryId: entity.categoryId,
      priority: entity.priority,
      status: entity.status,
      dueDate: entity.dueDate,
      completedAt: entity.completedAt,
      recurrence: entity.recurrence,
      isPinned: entity.isPinned,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory TaskModel.fromDrift(Task data) {
    return TaskModel(
      id: data.id,
      title: data.title,
      description: data.description,
      categoryId: data.categoryId,
      priority: data.priority,
      status: data.status,
      dueDate: data.dueDate,
      completedAt: data.completedAt,
      recurrence: TaskRecurrence.values.byName(data.recurrence),
      isPinned: data.isPinned,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      priority: priority,
      status: status,
      dueDate: dueDate,
      completedAt: completedAt,
      recurrence: recurrence,
      isPinned: isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  TasksCompanion toCompanion() {
    return TasksCompanion.insert(
      title: title,
      description: Value(description),
      categoryId: categoryId,
      priority: priority,
      status: status,
      dueDate: Value(dueDate),
      recurrence: Value(recurrence.name),
      isPinned: Value(isPinned),
    );
  }
}
