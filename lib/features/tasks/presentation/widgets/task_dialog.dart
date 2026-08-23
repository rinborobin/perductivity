import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../domain/entities/task_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import 'subtask_editor.dart';

class TaskDialog extends StatefulWidget {
  final TaskEntity? task;
  final List<CategoryEntity> categories;
  final void Function({
    required String title,
    String? description,
    required int categoryId,
    required TaskPriority priority,
    DateTime? dueDate,
    required TaskRecurrence recurrence,
    TaskStatus? status,
  })
  onSave;

  const TaskDialog({
    required this.onSave,
    required this.categories,
    this.task,
    super.key,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _selectedCategoryId;
  late TaskPriority _selectedPriority;
  TaskStatus? _selectedStatus;
  DateTime? _selectedDueDate;
  late TaskRecurrence _selectedRecurrence;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedCategoryId =
        widget.task?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id! : 0);
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedStatus = widget.task?.status;
    _selectedDueDate = widget.task?.dueDate;
    _selectedRecurrence = widget.task?.recurrence ?? TaskRecurrence.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return AppBottomSheet(
        title: 'No Categories',
        content: const Text(
          'Please create a category first before adding tasks.',
        ),
        actions: [
          AppActionButton(
            primary: false,
            label: 'OK',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }

    return AppBottomSheet(
      title: widget.task == null ? 'Create Task' : 'Edit Task',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                maxLength: 5000,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter task description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Category'),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategoryId = value);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Priority'),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(priority.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPriority = priority);
                          }
                        },
                        selectedColor: _getPriorityColor(
                          priority,
                        ).withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? _getPriorityColor(priority)
                              : null,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              if (widget.task != null) ...[
                const Text('Status'),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const Text('Due Date (optional)'),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (date != null) {
                    if (!context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedDueDate == null
                          ? TimeOfDay.now()
                          : TimeOfDay.fromDateTime(_selectedDueDate!),
                    );
                    if (!mounted) return;
                    setState(() {
                      _selectedDueDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time?.hour ?? 0,
                        time?.minute ?? 0,
                      );
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _selectedDueDate != null
                            ? DateFormat(
                                'EEE, MMM d, h:mm a',
                              ).format(_selectedDueDate!)
                            : 'Select date',
                      ),
                      const Spacer(),
                      if (_selectedDueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () =>
                              setState(() => _selectedDueDate = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Repeat'),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<TaskRecurrence>(
                initialValue: _selectedRecurrence,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                items: TaskRecurrence.values.map((recurrence) {
                  return DropdownMenuItem(
                    value: recurrence,
                    child: Text(_recurrenceLabel(recurrence)),
                  );
                }).toList(),
                validator: (value) {
                  if (value != TaskRecurrence.none &&
                      _selectedDueDate == null) {
                    return 'Select a due date for repeating tasks';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRecurrence = value);
                  }
                },
              ),
              if (widget.task != null) ...[
                const SizedBox(height: AppSpacing.md),
                SubtaskEditor(taskId: widget.task!.id!),
              ],
            ],
          ),
        ),
      ),
      actions: [
        AppActionButton(
          primary: false,
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppActionButton(
          label: 'Save',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                title: _titleController.text,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                categoryId: _selectedCategoryId,
                priority: _selectedPriority,
                dueDate: _selectedDueDate,
                recurrence: _selectedRecurrence,
                status: _selectedStatus,
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
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

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To do';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.archived:
        return 'Archived';
    }
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
