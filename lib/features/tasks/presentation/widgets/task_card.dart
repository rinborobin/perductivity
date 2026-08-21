import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_surface.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final String? categoryName;
  final String? categoryColor;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onTogglePin;
  final VoidCallback? onDelete;

  const TaskCard({
    required this.task,
    this.categoryName,
    this.categoryColor,
    this.onTap,
    this.onToggleComplete,
    this.onTogglePin,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final priorityColor = _getPriorityColor(task.priority);
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggleComplete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success
                          : colorScheme.outlineVariant,
                      width: 2,
                    ),
                    color: isCompleted ? AppColors.success : Colors.transparent,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (task.isPinned) ...[
                          Icon(
                            Icons.push_pin,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        if (categoryName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _parseColor(
                                categoryColor ?? '2563EB',
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              categoryName!,
                              style: TextStyle(
                                fontSize: 10,
                                color: _parseColor(categoryColor ?? '2563EB'),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            task.priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: priorityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: _isOverdue()
                                ? AppColors.error
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            DateFormat('MMM d').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 10,
                              color: _isOverdue()
                                  ? AppColors.error
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Task actions',
                onPressed: () => _showActions(context),
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
        ),
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

  Color _parseColor(String hexColor) {
    return Color(int.parse('0xFF${hexColor.replaceFirst('#', '')}'));
  }

  bool _isOverdue() {
    if (task.dueDate == null) return false;
    if (task.status == TaskStatus.completed) return false;
    return task.dueDate!.isBefore(DateTime.now());
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) => AppBottomSheet(
        title: 'Task actions',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TaskActionTile(
              icon: task.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              label: task.isPinned ? 'Remove pin' : 'Pin task',
              onTap: onTogglePin == null
                  ? null
                  : () {
                      Navigator.pop(sheetContext);
                      onTogglePin!.call();
                    },
            ),
            _TaskActionTile(
              icon: Icons.delete_outline,
              label: 'Delete task',
              color: AppColors.error,
              onTap: onDelete == null
                  ? null
                  : () {
                      Navigator.pop(sheetContext);
                      onDelete!.call();
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
}

class _TaskActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _TaskActionTile({
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
