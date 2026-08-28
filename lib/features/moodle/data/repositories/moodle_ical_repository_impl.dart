import '../../../../core/database/database.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../domain/repositories/moodle_ical_repository.dart';
import '../datasource/moodle_ical_client.dart';
import '../models/moodle_calendar_event.dart';

class MoodleIcalRepositoryImpl implements MoodleIcalRepository {
  final MoodleIcalClient _client;
  final TaskRepository _taskRepository;
  final CategoryRepository _categoryRepository;

  static const _categoryName = 'Moodle';
  static const _categoryColor = 'E53935';
  static const _categoryIcon = '60214';

  MoodleIcalRepositoryImpl(
    this._client,
    this._taskRepository,
    this._categoryRepository,
  );

  @override
  Future<MoodleCalendarImportResult> importCalendar(String url) async {
    final events = await _client.fetchEvents(url);
    final category = await _ensureCategory();

    var created = 0;
    var updated = 0;

    for (final event in events) {
      final existing = await _taskRepository.getTaskByExternalId(event.uid);
      final task = _mapEventToTask(event, category.id!);

      if (existing == null) {
        await _taskRepository.createTask(task);
        created++;
      } else {
        await _taskRepository.updateTask(existing.id!, task);
        updated++;
      }
    }

    return MoodleCalendarImportResult(
      imported: created + updated,
      created: created,
      updated: updated,
    );
  }

  TaskEntity _mapEventToTask(MoodleCalendarEvent event, int categoryId) {
    return TaskEntity(
      externalId: event.uid,
      title: event.summary,
      description: event.description ?? event.location,
      categoryId: categoryId,
      priority: TaskPriority.medium,
      status: TaskStatus.todo,
      dueDate: event.startDate,
    );
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
