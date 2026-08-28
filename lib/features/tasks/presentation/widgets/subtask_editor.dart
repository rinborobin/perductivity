import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_surface.dart';
import '../../domain/entities/subtask_entity.dart';
import '../providers/subtask_providers.dart';
import '../providers/task_providers.dart';
import '../providers/task_list_provider.dart';

class SubtaskEditor extends ConsumerStatefulWidget {
  final int taskId;
  final bool showTitle;

  const SubtaskEditor({
    required this.taskId,
    this.showTitle = true,
    super.key,
  });

  @override
  ConsumerState<SubtaskEditor> createState() => _SubtaskEditorState();
}

class _SubtaskEditorState extends ConsumerState<SubtaskEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtasksState = ref.watch(subtaskListProvider(widget.taskId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          const Text('Subtasks', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
        ],
        subtasksState.when(
          data: (subtasks) => Column(
            children: [
              ...subtasks.map((subtask) => _buildSubtask(context, subtask)),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addSubtask(),
                decoration: const InputDecoration(
                  labelText: 'Add a step',
                  hintText: 'Break this task into a smaller step',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: AppActionButton(
                  primary: false,
                  icon: Icons.add,
                  label: 'Add step',
                  onPressed: _addSubtask,
                ),
              ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => const Text('Subtasks unavailable'),
        ),
      ],
    );
  }

  Widget _buildSubtask(BuildContext context, SubtaskEntity subtask) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          InkWell(
            onTap: () => _toggleSubtask(subtask),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                subtask.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: subtask.isCompleted
                    ? AppColors.success
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: subtask.isCompleted
                    ? colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete step',
            onPressed: () => _deleteSubtask(subtask),
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  Future<void> _addSubtask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    await ref
        .read(taskRepositoryProvider)
        .createSubtask(SubtaskEntity(taskId: widget.taskId, title: title));
    if (!mounted) return;
    _controller.clear();
    ref.invalidate(subtaskListProvider(widget.taskId));
    ref.invalidate(subtaskProgressProvider);
  }

  Future<void> _toggleSubtask(SubtaskEntity subtask) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.toggleSubtask(subtask.id!, !subtask.isCompleted);
    final subtasks = await repo.getSubtasks(widget.taskId);
    final task = await repo.getTaskById(widget.taskId);
    if (subtasks.isNotEmpty) {
      final allDone = subtasks.every((s) => s.isCompleted);
      if (allDone && task?.status != TaskStatus.completed) {
        await repo.completeTask(widget.taskId);
      } else if (!allDone && task?.status == TaskStatus.completed) {
        await repo.uncompleteTask(widget.taskId);
      }
    }
    if (!mounted) return;
    ref.invalidate(subtaskListProvider(widget.taskId));
    ref.invalidate(subtaskProgressProvider);
    ref.read(taskListProvider.notifier).loadTasks();
  }

  Future<void> _deleteSubtask(SubtaskEntity subtask) async {
    await ref.read(taskRepositoryProvider).deleteSubtask(subtask.id!);
    if (!mounted) return;
    ref.invalidate(subtaskListProvider(widget.taskId));
    ref.invalidate(subtaskProgressProvider);
  }
}
