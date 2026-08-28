import 'package:flutter_test/flutter_test.dart';
import 'package:perductivity/core/database/database.dart';
import 'package:perductivity/features/categories/domain/entities/category_entity.dart';
import 'package:perductivity/features/categories/domain/repositories/category_repository.dart';
import 'package:perductivity/features/planner/data/repositories/ai_planner_repository_impl.dart';
import 'package:perductivity/features/planner/data/storage/ai_settings_store.dart';
import 'package:perductivity/features/planner/data/models/ai_plan.dart';
import 'package:perductivity/features/tasks/domain/entities/subtask_entity.dart';
import 'package:perductivity/features/tasks/domain/entities/task_entity.dart';
import 'package:perductivity/features/tasks/domain/repositories/task_repository.dart';

class _FakeTaskRepository implements TaskRepository {
  final List<TaskEntity> createdTasks = [];
  final List<SubtaskEntity> createdSubtasks = [];

  @override
  Future<int> createTask(TaskEntity task) async {
    createdTasks.add(task);
    return createdTasks.length;
  }

  @override
  Future<int> createSubtask(SubtaskEntity subtask) async {
    createdSubtasks.add(subtask);
    return createdSubtasks.length;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeCategoryRepository implements CategoryRepository {
  final List<CategoryEntity> categories = [
    const CategoryEntity(id: 1, name: 'Existing', color: 'FFFFFF', icon: '1'),
  ];

  @override
  Future<List<CategoryEntity>> getAllCategories() async => categories;

  @override
  Future<int> createCategory(CategoryEntity category) async {
    categories.add(category.copyWith(id: categories.length + 1));
    return categories.length;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSettingsStore extends AiSettingsStore {
  @override
  Future<String?> readApiKey() async => 'dummy-key';

  @override
  Future<String> readModel() async => AiSettingsStore.defaultModel;
}

void main() {
  test('importDayPlans creates tasks with due dates and subtasks', () async {
    final taskRepo = _FakeTaskRepository();
    final categoryRepo = _FakeCategoryRepository();
    final repository = AiPlannerRepositoryImpl(
      _FakeSettingsStore(),
      taskRepo,
      categoryRepo,
    );

    final plan = [
      AiDayPlan(
        date: DateTime(2026, 9, 1),
        tasks: [
          AiPlanTask(
            title: 'Write proposal',
            description: 'First draft',
            priority: TaskPriority.high,
            subtasks: ['Outline', 'Draft intro'],
          ),
        ],
      ),
    ];

    final count = await repository.importDayPlans(plan);

    expect(count, 1);
    expect(taskRepo.createdTasks, hasLength(1));
    final task = taskRepo.createdTasks.first;
    expect(task.title, 'Write proposal');
    expect(task.dueDate, DateTime(2026, 9, 1));
    expect(task.priority, TaskPriority.high);
    expect(task.categoryId, 2);
    expect(taskRepo.createdSubtasks, hasLength(2));
    expect(taskRepo.createdSubtasks.first.title, 'Outline');
  });
}
