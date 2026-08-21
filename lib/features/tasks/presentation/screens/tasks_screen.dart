import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../domain/entities/task_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/providers/category_list_provider.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_filter_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_dialog.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskListProvider);
    final categoriesState = ref.watch(categoryListProvider);
    final activeFilter = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: tasksState.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return _buildEmptyState(context);
          }

          final filteredTasks = applyTaskFilter(
            tasks,
            activeFilter,
            now: DateTime.now(),
          );
          final activeTasks = filteredTasks
              .where((t) => t.status != TaskStatus.archived)
              .toList();
          final pinnedTasks = activeTasks.where((t) => t.isPinned).toList();
          final unpinnedTasks = activeTasks.where((t) => !t.isPinned).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(taskListProvider.notifier).loadTasks(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (pinnedTasks.isNotEmpty) ...[
                  const Text(
                    'Pinned',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...pinnedTasks.map(
                    (task) =>
                        _buildTaskCard(context, ref, task, categoriesState),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (unpinnedTasks.isNotEmpty) ...[
                  if (pinnedTasks.isNotEmpty)
                    const Text(
                      'All Tasks',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  if (pinnedTasks.isNotEmpty)
                    const SizedBox(height: AppSpacing.sm),
                  ...unpinnedTasks.map(
                    (task) =>
                        _buildTaskCard(context, ref, task, categoriesState),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref, categoriesState),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
    AsyncValue<List<CategoryEntity>> categoriesState,
  ) {
    final categories = categoriesState.valueOrNull ?? [];
    final category = categories
        .where((c) => c.id == task.categoryId)
        .firstOrNull;

    return TaskCard(
      task: task,
      categoryName: category?.name,
      categoryColor: category?.color,
      onTap: () => _showEditDialog(context, ref, task, categoriesState),
      onToggleComplete: () {
        if (task.status == TaskStatus.completed) {
          ref.read(taskListProvider.notifier).uncompleteTask(task.id!);
        } else {
          ref.read(taskListProvider.notifier).completeTask(task.id!);
        }
      },
      onTogglePin: () {
        ref.read(taskListProvider.notifier).togglePin(task.id!, !task.isPinned);
      },
      onDelete: () => _confirmDelete(context, ref, task.id!),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_box_outline_blank,
            size: 64,
            color: AppColors.lightTextDisabled,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap + to create your first task',
            style: TextStyle(color: AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryEntity>> categoriesState,
  ) {
    final categories = categoriesState.valueOrNull ?? [];
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        categories: categories,
        onSave:
            ({
              required title,
              description,
              required categoryId,
              required priority,
              dueDate,
              status,
            }) {
              ref
                  .read(taskListProvider.notifier)
                  .createTask(
                    title: title,
                    description: description,
                    categoryId: categoryId,
                    priority: priority,
                    dueDate: dueDate,
                  );
            },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
    AsyncValue<List<CategoryEntity>> categoriesState,
  ) {
    final categories = categoriesState.valueOrNull ?? [];
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        categories: categories,
        onSave:
            ({
              required title,
              description,
              required categoryId,
              required priority,
              dueDate,
              status,
            }) {
              ref
                  .read(taskListProvider.notifier)
                  .updateTask(
                    id: task.id!,
                    title: title,
                    description: description,
                    categoryId: categoryId,
                    priority: priority,
                    status: status ?? task.status,
                    dueDate: dueDate,
                  );
            },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(taskFilterProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TaskFilter.values.map((filter) {
                final isSelected = currentFilter == filter;
                return FilterChip(
                  label: Text(_filterLabel(filter)),
                  selected: isSelected,
                  onSelected: (_) {
                    ref.read(taskFilterProvider.notifier).setFilter(filter);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _filterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.overdue:
        return 'Overdue';
      case TaskFilter.pinned:
        return 'Pinned';
    }
  }
}
