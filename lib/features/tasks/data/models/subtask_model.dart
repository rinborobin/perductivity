import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/subtask_entity.dart';

class SubtaskModel {
  final int? id;
  final int taskId;
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubtaskModel({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory SubtaskModel.fromEntity(SubtaskEntity entity) {
    return SubtaskModel(
      id: entity.id,
      taskId: entity.taskId,
      title: entity.title,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory SubtaskModel.fromDrift(Subtask data) {
    return SubtaskModel(
      id: data.id,
      taskId: data.taskId,
      title: data.title,
      isCompleted: data.isCompleted,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  SubtaskEntity toEntity() {
    return SubtaskEntity(
      id: id,
      taskId: taskId,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  SubtasksCompanion toCompanion() {
    return SubtasksCompanion.insert(
      taskId: taskId,
      title: title,
      isCompleted: Value(isCompleted),
    );
  }
}
