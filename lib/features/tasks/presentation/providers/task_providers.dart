import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/database_provider.dart';
import '../../data/datasource/task_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';

final taskDataSourceProvider = Provider<TaskDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return TaskDataSource(db);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final dataSource = ref.watch(taskDataSourceProvider);
  return TaskRepositoryImpl(dataSource);
});
