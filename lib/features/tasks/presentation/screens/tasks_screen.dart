import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../domain/entities/task_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/providers/category_list_provider.dart';
import '../providers/task_list_provider.dart';
import '../providers/task_filter_provider.dart';
import '../providers/subtask_providers.dart';
import '../widgets/task_card.dart';
import '../widgets/task_dialog.dart';
import 'task_detail_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(taskListProvider);
    final categoriesState = ref.watch(categoryListProvider);
    final subtaskProgressState = ref.watch(subtaskProgressProvider);
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
            return _buildEmptyState(context, ref, categoriesState);
          }

          final subtaskProgress = subtaskProgressState.valueOrNull ?? {};
          final searchedTasks = _filterBySearch(tasks);
          final filteredTasks = applyTaskFilter(
            searchedTasks,
            activeFilter,
            now: DateTime.now(),
          );
          final activeTasks = filteredTasks
              .where((t) => t.status != TaskStatus.archived)
              .toList();
          final pinnedTasks = activeTasks.where((t) => t.isPinned).toList();
          final unpinnedTasks = activeTasks.where((t) => !t.isPinned).toList();

          if (activeTasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.read(taskListProvider.notifier).loadTasks(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _buildSearchField(context),
                  _buildNoResults(context, activeFilter),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(taskListProvider.notifier).loadTasks(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _buildSearchField(context),
                if (pinnedTasks.isNotEmpty) ...[
                  const Text(
                    'Pinned',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...pinnedTasks.map(
                    (task) => _buildTaskCard(
                      context,
                      ref,
                      task,
                      categoriesState,
                      subtaskProgress,
                    ),
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
                    (task) => _buildTaskCard(
                      context,
                      ref,
                      task,
                      categoriesState,
                      subtaskProgress,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: AppActionButton(
            icon: Icons.refresh,
            label: 'Try again',
            onPressed: () => ref.read(taskListProvider.notifier).loadTasks(),
          ),
        ),
      ),
      floatingActionButton: AppActionButton(
        label: 'Add task',
        icon: Icons.add,
        onPressed: () => _showCreateDialog(context, ref, categoriesState),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
    AsyncValue<List<CategoryEntity>> categoriesState,
    Map<int, List<int>> subtaskProgress,
  ) {
    final categories = categoriesState.valueOrNull ?? [];
    final category = categories
        .where((c) => c.id == task.categoryId)
        .firstOrNull;
    final progress = subtaskProgress[task.id] ?? [0, 0];

    void openDetail() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TaskDetailScreen(taskId: task.id!),
        ),
      );
    }

    return TaskCard(
      task: task,
      categoryName: category?.name,
      categoryColor: category?.color,
      onTap: openDetail,
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
      subtaskTotal: progress[0],
      subtaskDone: progress[1],
      onViewSubtasks: openDetail,
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search tasks',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.clear),
                ),
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, TaskFilter filter) {
    final hasSearch = _searchQuery.trim().isNotEmpty;
    final title = hasSearch ? 'No matching tasks' : 'No tasks in this view';
    final message = hasSearch
        ? 'Try a different search term.'
        : 'Choose another filter to see more tasks.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.filter_alt_off,
            size: 56,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (filter != TaskFilter.all) ...[
            const SizedBox(height: AppSpacing.md),
            AppActionButton(
              primary: false,
              label: 'Show all tasks',
              onPressed: () => ref
                  .read(taskFilterProvider.notifier)
                  .setFilter(TaskFilter.all),
            ),
          ],
        ],
      ),
    );
  }

  List<TaskEntity> _filterBySearch(List<TaskEntity> tasks) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(query) ||
          (task.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryEntity>> categoriesState,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_box_outline_blank,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap + to create your first task',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppActionButton(
            icon: Icons.add,
            label: 'Create task',
            onPressed: () => _showCreateDialog(context, ref, categoriesState),
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TaskDialog(
        categories: categories,
        onSave:
            ({
              required title,
              description,
              required categoryId,
              required priority,
              dueDate,
              required recurrence,
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
                    recurrence: recurrence,
                  );
            },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => AppBottomSheet(
        title: 'Delete Task',
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          AppActionButton(
            primary: false,
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppActionButton(
            label: 'Delete',
            danger: true,
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.read(taskFilterProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => AppBottomSheet(
        title: 'Filter tasks',
        content: Wrap(
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
        actions: [
          AppActionButton(
            primary: false,
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
