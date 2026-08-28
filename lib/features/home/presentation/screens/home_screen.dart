import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/providers/category_list_provider.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_list_provider.dart';
import '../../../tasks/presentation/providers/subtask_providers.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/presentation/widgets/task_dialog.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_surface.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskListProvider);
    final categoriesState = ref.watch(categoryListProvider);
    final subtaskProgressState = ref.watch(subtaskProgressProvider);

    return Scaffold(
      floatingActionButton: _HomeAddButton(
        onPressed: () => _showCreateTask(context, ref, categoriesState),
      ),
      body: SafeArea(
        child: tasksState.when(
          data: (tasks) {
            final categories = categoriesState.valueOrNull ?? [];
            final subtaskProgress = subtaskProgressState.valueOrNull ?? {};
            final now = DateTime.now();
            final todayTasks = _getTodayTasks(tasks, now);
            final upcomingTasks = _getUpcomingTasks(tasks, now);
            final unscheduledTasks = _getUnscheduledTasks(tasks);
            final completedToday = _getCompletedToday(tasks, now);
            final pendingCount = tasks.where((task) {
              return task.status != TaskStatus.completed &&
                  task.status != TaskStatus.archived;
            }).length;

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(taskListProvider.notifier).loadTasks();
                await ref.read(categoryListProvider.notifier).loadCategories();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                children: [
                  _buildHeader(context, now),
                  const SizedBox(height: AppSpacing.xl),
                  _buildOverview(
                    pendingCount: pendingCount,
                    completedToday: completedToday.length,
                    dueToday: todayTasks.length,
                    completedDueToday: todayTasks
                        .where((task) => task.status == TaskStatus.completed)
                        .length,
                  ),
                  if (tasks.isEmpty)
                    _buildFirstTaskState(context, ref, categoriesState),
                  if (tasks.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader(
                      context,
                      'Today',
                      todayTasks.length,
                      onViewAll: todayTasks.length > 5
                          ? () => context.go('/tasks')
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (todayTasks.isEmpty)
                      _buildSectionEmpty(
                        context: context,
                        icon: Icons.wb_sunny_outlined,
                        title: 'Nothing scheduled today',
                        message: 'Add a task to make a plan for your day.',
                        onAction: () =>
                            _showCreateTask(context, ref, categoriesState),
                      )
                    else
                    ...todayTasks
                        .take(5)
                        .map(
                          (task) => _buildTaskCard(
                            context,
                            ref,
                            task,
                            categories,
                            subtaskProgress,
                          ),
                        ),
                    if (upcomingTasks.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionHeader(
                        context,
                        'Upcoming',
                        upcomingTasks.length,
                        onViewAll: () => context.go('/tasks'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...upcomingTasks
                          .take(5)
                          .map(
                            (task) => _buildTaskCard(
                              context,
                              ref,
                              task,
                              categories,
                              subtaskProgress,
                            ),
                          ),
                    ],
                    if (unscheduledTasks.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionHeader(
                        context,
                        'No date',
                        unscheduledTasks.length,
                        onViewAll: () => context.go('/tasks'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...unscheduledTasks
                          .take(5)
                          .map(
                            (task) => _buildTaskCard(
                              context,
                              ref,
                              task,
                              categories,
                              subtaskProgress,
                            ),
                          ),
                    ],
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load your tasks'),
                const SizedBox(height: AppSpacing.sm),
                AppActionButton(
                  icon: Icons.refresh,
                  label: 'Try again',
                  onPressed: () =>
                      ref.read(taskListProvider.notifier).loadTasks(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime now) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today,',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                DateFormat('d MMMM yyyy').format(now),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _HomeHeaderButton(
          icon: Icons.search,
          tooltip: 'Search tasks',
          onPressed: () => context.go('/tasks'),
        ),
        _HomeHeaderButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onPressed: () => context.go('/settings'),
        ),
      ],
    );
  }

  Widget _buildOverview({
    required int pendingCount,
    required int completedToday,
    required int dueToday,
    required int completedDueToday,
  }) {
    final progress = dueToday == 0 ? 0.0 : completedDueToday / dueToday;

    return AppSurface(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's focus",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$completedDueToday/$dueToday done',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _OverviewMetric(
                  label: 'Pending',
                  value: pendingCount.toString(),
                  color: AppColors.warning,
                ),
                _OverviewMetric(
                  label: 'Due today',
                  value: dueToday.toString(),
                  color: AppColors.primary,
                ),
                _OverviewMetric(
                  label: 'Done today',
                  value: completedToday.toString(),
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count, {
    VoidCallback? onViewAll,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        if (onViewAll != null)
          AppActionButton(
            primary: false,
            label: 'View all',
            onPressed: onViewAll,
          ),
      ],
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
    List<CategoryEntity> categories,
    Map<int, List<int>> subtaskProgress,
  ) {
    final category = categories
        .where((item) => item.id == task.categoryId)
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
      subtaskTotal: progress[0],
      subtaskDone: progress[1],
      onViewSubtasks: openDetail,
    );
  }

  Widget _buildSectionEmpty({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required VoidCallback onAction,
  }) {
    return AppSurface(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              onPressed: onAction,
              tooltip: 'Add task',
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstTaskState(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryEntity>> categoriesState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.task_alt, size: 56, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Start with one task',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Create a small next step and build momentum.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          AppActionButton(
            onPressed: () => _showCreateTask(context, ref, categoriesState),
            icon: Icons.add,
            label: 'Create your first task',
          ),
        ],
      ),
    );
  }

  void _showCreateTask(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryEntity>> categoriesState,
  ) {
    final categories = categoriesState.valueOrNull ?? [];
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Create a category before adding a task.'),
          action: SnackBarAction(
            label: 'SET UP',
            onPressed: () => context.push('/settings/categories'),
          ),
        ),
      );
      return;
    }

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

  List<TaskEntity> _getTodayTasks(List<TaskEntity> tasks, DateTime now) {
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return tasks.where((task) {
      if (task.status == TaskStatus.archived || task.dueDate == null) {
        return false;
      }
      return !task.dueDate!.isBefore(startOfDay) &&
          task.dueDate!.isBefore(endOfDay);
    }).toList();
  }

  List<TaskEntity> _getUpcomingTasks(List<TaskEntity> tasks, DateTime now) {
    final endOfToday = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    return tasks.where((task) {
      if (task.status == TaskStatus.completed ||
          task.status == TaskStatus.archived ||
          task.dueDate == null) {
        return false;
      }
      return !task.dueDate!.isBefore(endOfToday);
    }).toList()..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  List<TaskEntity> _getUnscheduledTasks(List<TaskEntity> tasks) {
    return tasks.where((task) {
      return task.dueDate == null &&
          task.status != TaskStatus.completed &&
          task.status != TaskStatus.archived;
    }).toList();
  }

  List<TaskEntity> _getCompletedToday(List<TaskEntity> tasks, DateTime now) {
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return tasks.where((task) {
      if (task.status != TaskStatus.completed || task.completedAt == null) {
        return false;
      }
      return !task.completedAt!.isBefore(startOfDay) &&
          task.completedAt!.isBefore(endOfDay);
    }).toList();
  }
}

class _OverviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HomeHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: tooltip,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Ink(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _HomeAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Add task',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Ink(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(Icons.add, color: colorScheme.onPrimary, size: 30),
          ),
        ),
      ),
    );
  }
}
