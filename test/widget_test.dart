import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:perductivity/app/app.dart';
import 'package:perductivity/core/database/database.dart';
import 'package:perductivity/features/categories/domain/entities/category_entity.dart';
import 'package:perductivity/features/categories/domain/repositories/category_repository.dart';
import 'package:perductivity/features/categories/presentation/providers/category_list_provider.dart';
import 'package:perductivity/features/tasks/domain/entities/task_entity.dart';
import 'package:perductivity/features/tasks/domain/entities/subtask_entity.dart';
import 'package:perductivity/features/tasks/domain/repositories/task_repository.dart';
import 'package:perductivity/features/tasks/presentation/providers/task_list_provider.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home shows the primary add-task action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump();

    expect(find.text('Today,'), findsOneWidget);
    expect(find.bySemanticsLabel('Add task'), findsOneWidget);
  });
}

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      taskListProvider.overrideWith(
        (ref) => TaskListNotifier(_FakeTaskRepository()),
      ),
      categoryListProvider.overrideWith(
        (ref) => CategoryListNotifier(_FakeCategoryRepository()),
      ),
    ],
    child: const App(),
  );
}

class _FakeTaskRepository implements TaskRepository {
  @override
  Future<List<TaskEntity>> getAllTasks() async => [];

  @override
  Future<List<TaskEntity>> getTasksByStatus(TaskStatus status) async => [];

  @override
  Future<List<TaskEntity>> getTasksByCategory(int categoryId) async => [];

  @override
  Future<List<TaskEntity>> getTasksDueToday() async => [];

  @override
  Future<List<TaskEntity>> getUpcomingTasks({int limit = 10}) async => [];

  @override
  Future<List<TaskEntity>> searchTasks(String query) async => [];

  @override
  Future<TaskEntity?> getTaskById(int id) async => null;

  @override
  Future<int> createTask(TaskEntity task) async => 1;

  @override
  Future<bool> updateTask(int id, TaskEntity task) async => true;

  @override
  Future<bool> completeTask(int id) async => true;

  @override
  Future<bool> uncompleteTask(int id) async => true;

  @override
  Future<bool> archiveTask(int id) async => true;

  @override
  Future<bool> togglePin(int id, bool isPinned) async => true;

  @override
  Future<bool> deleteTask(int id) async => true;

  @override
  Future<List<SubtaskEntity>> getSubtasks(int taskId) async => [];

  @override
  Future<int> createSubtask(SubtaskEntity subtask) async => 1;

  @override
  Future<bool> toggleSubtask(int id, bool isCompleted) async => true;

  @override
  Future<bool> deleteSubtask(int id) async => true;

  @override
  Stream<List<TaskEntity>> watchAllTasks() => Stream.value([]);

  @override
  Stream<List<TaskEntity>> watchTasksByStatus(TaskStatus status) =>
      Stream.value([]);

  @override
  Future<Map<TaskStatus, int>> getTaskCounts() async => {};
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryEntity>> getAllCategories() async => [];

  @override
  Future<CategoryEntity?> getCategoryById(int id) async => null;

  @override
  Future<int> createCategory(CategoryEntity category) async => 1;

  @override
  Future<bool> updateCategory(int id, CategoryEntity category) async => true;

  @override
  Future<bool> deleteCategory(int id) async => true;

  @override
  Stream<List<CategoryEntity>> watchAllCategories() => Stream.value([]);
}
