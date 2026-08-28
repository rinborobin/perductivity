import 'package:equatable/equatable.dart';
import '../../../../core/database/database.dart';

class AiPlanTask extends Equatable {
  final String title;
  final String? description;
  final TaskPriority priority;
  final List<String> subtasks;

  const AiPlanTask({
    required this.title,
    this.description,
    required this.priority,
    this.subtasks = const [],
  });

  AiPlanTask copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    List<String>? subtasks,
  }) {
    return AiPlanTask(
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  @override
  List<Object?> get props => [title, description, priority, subtasks];
}

class AiDayPlan extends Equatable {
  final DateTime date;
  final List<AiPlanTask> tasks;

  const AiDayPlan({required this.date, required this.tasks});

  AiDayPlan copyWith({DateTime? date, List<AiPlanTask>? tasks}) {
    return AiDayPlan(date: date ?? this.date, tasks: tasks ?? this.tasks);
  }

  @override
  List<Object?> get props => [date, tasks];
}
