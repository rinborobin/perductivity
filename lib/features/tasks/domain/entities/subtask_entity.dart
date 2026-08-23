import 'package:equatable/equatable.dart';

class SubtaskEntity extends Equatable {
  final int? id;
  final int taskId;
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SubtaskEntity({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    taskId,
    title,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}
