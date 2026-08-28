import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/repositories/ai_planner_repository_impl.dart';
import '../../data/storage/ai_settings_store.dart';
import '../../domain/repositories/ai_planner_repository.dart';

final aiSettingsStoreProvider = Provider<AiSettingsStore>((ref) {
  return AiSettingsStore();
});

final aiPlannerRepositoryProvider = Provider<AiPlannerRepository>((ref) {
  final settingsStore = ref.watch(aiSettingsStoreProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return AiPlannerRepositoryImpl(
    settingsStore,
    taskRepository,
    categoryRepository,
  );
});
