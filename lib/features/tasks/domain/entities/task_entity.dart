import 'package:equatable/equatable.dart';
import '../../../../core/database/database.dart';

class TaskEntity extends Equatable {
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

  const TaskEntity({
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

  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    int? categoryId,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    TaskRecurrence? recurrence,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      recurrence: recurrence ?? this.recurrence,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    categoryId,
    priority,
    status,
    dueDate,
    completedAt,
    recurrence,
    isPinned,
    createdAt,
    updatedAt,
  ];
}
