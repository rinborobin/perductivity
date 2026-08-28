import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../../core/database/database.dart';
import '../../../tasks/domain/entities/subtask_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../datasource/ai_planner_client.dart';
import '../models/ai_plan.dart';
import '../storage/ai_settings_store.dart';
import '../../domain/repositories/ai_planner_repository.dart';

class AiPlannerRepositoryImpl implements AiPlannerRepository {
  final AiSettingsStore _settingsStore;
  final TaskRepository _taskRepository;
  final CategoryRepository _categoryRepository;

  static const _categoryName = 'AI Plan';
  static const _categoryColor = '7E57C2';
  static const _categoryIcon = '59497';

  AiPlannerRepositoryImpl(
    this._settingsStore,
    this._taskRepository,
    this._categoryRepository,
  );

  @override
  Future<List<AiDayPlan>> generatePlan({
    required String scheduleText,
    required DateTime monthStart,
    required DateTime monthEnd,
    List<int>? pdfBytes,
  }) async {
    final apiKey = await _settingsStore.readApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw AiPlannerException(
        'Set your Gemini API key in AI Planner settings.',
      );
    }
    final model = await _settingsStore.readModel();
    final client = AiPlannerClient(apiKey: apiKey, modelName: model);
    return client.generatePlan(
      scheduleText: scheduleText,
      monthStart: monthStart,
      monthEnd: monthEnd,
      pdfBytes: pdfBytes,
    );
  }

  @override
  Future<int> importDayPlans(List<AiDayPlan> days) async {
    final category = await _ensureCategory();
    var created = 0;

    for (final day in days) {
      for (final task in day.tasks) {
        final taskId = await _taskRepository.createTask(
          TaskEntity(
            title: task.title,
            description: task.description,
            categoryId: category.id!,
            priority: task.priority,
            status: TaskStatus.todo,
            dueDate: day.date,
          ),
        );

        for (final subtask in task.subtasks) {
          await _taskRepository.createSubtask(
            SubtaskEntity(title: subtask, taskId: taskId),
          );
        }
        created++;
      }
    }

    return created;
  }

  Future<CategoryEntity> _ensureCategory() async {
    final categories = await _categoryRepository.getAllCategories();
    final existing = categories
        .where((c) => c.name == _categoryName)
        .firstOrNull;
    if (existing != null) return existing;

    final id = await _categoryRepository.createCategory(
      const CategoryEntity(
        name: _categoryName,
        color: _categoryColor,
        icon: _categoryIcon,
      ),
    );
    return CategoryEntity(
      id: id,
      name: _categoryName,
      color: _categoryColor,
      icon: _categoryIcon,
    );
  }
}
