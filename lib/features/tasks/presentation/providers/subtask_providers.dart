import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subtask_entity.dart';
import 'task_providers.dart';

final subtaskListProvider = FutureProvider.family<List<SubtaskEntity>, int>((
  ref,
  taskId,
) async {
  return ref.watch(taskRepositoryProvider).getSubtasks(taskId);
});

final subtaskProgressProvider = FutureProvider<Map<int, List<int>>>((ref) async {
  return ref.watch(taskRepositoryProvider).getSubtaskProgress();
});
