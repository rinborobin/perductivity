import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_surface.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/providers/category_list_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_list_provider.dart';
import '../widgets/subtask_editor.dart';
import '../widgets/task_dialog.dart';

class TaskDetailScreen extends ConsumerWidget {
  final int taskId;

  const TaskDetailScreen({required this.taskId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskListProvider);
    final categoriesState = ref.watch(categoryListProvider);

    return tasksState.when(
      data: (tasks) {
        final task = tasks.where((t) => t.id == taskId).firstOrNull;
        if (task == null) {
          return const Scaffold(
            body: Center(child: Text('Task not found')),
          );
        }
        final categories = categoriesState.valueOrNull ?? [];
        final category = categories
            .where((c) => c.id == task.categoryId)
            .firstOrNull;
        return _buildContent(context, ref, task, category);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) {
        return const Scaffold(
          body: Center(child: Text('Unable to load task')),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
    CategoryEntity? category,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = task.status == TaskStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit task',
            onPressed: () => _showEditDialog(context, ref, task),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More actions',
            onPressed: () => _showActions(context, ref, task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _toggleComplete(context, ref, task),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.success
                                : colorScheme.outlineVariant,
                            width: 2,
                          ),
                          color: isCompleted
                              ? AppColors.success
                              : Colors.transparent,
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompleted
                                      ? colorScheme.onSurfaceVariant
                                      : null,
                                ),
                          ),
                          if (task.description != null &&
                              task.description!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              task.description!,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (task.isPinned)
                      const Padding(
                        padding: EdgeInsets.only(left: AppSpacing.xs),
                        child: Icon(
                          Icons.push_pin,
                          size: 18,
                          color: AppColors.warning,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (category != null)
                      _buildChip(
                        category.name,
                        _parseColor(category.color),
                      ),
                    _buildChip(
                      task.priority.name.toUpperCase(),
                      _getPriorityColor(task.priority),
                    ),
                    if (task.dueDate != null)
                      _buildChip(
                        DateFormat('EEE, MMM d, h:mm a').format(
                          task.dueDate!,
                        ),
                        colorScheme.primary,
                      ),
                    if (task.recurrence != TaskRecurrence.none)
                      _buildChip(
                        _recurrenceLabel(task.recurrence),
                        colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SubtaskEditor(taskId: taskId, showTitle: false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _toggleComplete(BuildContext context, WidgetRef ref, TaskEntity task) {
    if (task.status == TaskStatus.completed) {
      ref.read(taskListProvider.notifier).uncompleteTask(task.id!);
    } else {
      ref.read(taskListProvider.notifier).completeTask(task.id!);
    }
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
  ) {
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TaskDialog(
        task: task,
        categories: categories,
        onSave: ({
          required title,
          description,
          required categoryId,
          required priority,
          dueDate,
          required recurrence,
          status,
        }) {
          ref.read(taskListProvider.notifier).updateTask(
            id: task.id!,
            title: title,
            description: description,
            categoryId: categoryId,
            priority: priority,
            status: status ?? task.status,
            dueDate: dueDate,
            recurrence: recurrence,
          );
        },
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, TaskEntity task) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) => AppBottomSheet(
        title: 'Task actions',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionTile(
              icon: task.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              label: task.isPinned ? 'Remove pin' : 'Pin task',
              onTap: () {
                Navigator.pop(sheetContext);
                ref
                    .read(taskListProvider.notifier)
                    .togglePin(task.id!, !task.isPinned);
              },
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              label: 'Delete task',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, ref, task.id!);
              },
            ),
          ],
        ),
        actions: [
          AppActionButton(
            primary: false,
            label: 'Close',
            onPressed: () => Navigator.pop(sheetContext),
          ),
        ],
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
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  Color _parseColor(String? hexColor) {
    return Color(
      int.parse('0xFF${(hexColor ?? '55B58A').replaceFirst('#', '')}'),
    );
  }

  String _recurrenceLabel(TaskRecurrence recurrence) {
    switch (recurrence) {
      case TaskRecurrence.none:
        return 'Does not repeat';
      case TaskRecurrence.daily:
        return 'Every day';
      case TaskRecurrence.weekly:
        return 'Every week';
      case TaskRecurrence.monthly:
        return 'Every month';
    }
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Theme.of(context).colorScheme.onSurface;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, color: foreground),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
