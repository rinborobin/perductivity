import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_list_provider.dart';
import '../../../categories/presentation/providers/category_list_provider.dart';
import '../../../tasks/presentation/widgets/task_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(taskListProvider);
    final categoriesState = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: tasksState.when(
        data: (tasks) {
          final categories = categoriesState.valueOrNull ?? [];
          return Column(
            children: [
              _buildMonthHeader(),
              _buildWeekdayLabels(context),
              _buildCalendarGrid(context, tasks),
              const Divider(),
              Expanded(child: _buildSelectedDayTasks(tasks, categories)),
            ],
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
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            tooltip: 'Today',
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime.now();
                _selectedDate = DateTime.now();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, List<TaskEntity> tasks) {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );
    final startWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final previousMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month - 1,
      0,
    );
    final daysFromPrevMonth = startWeekday - 1;

    final totalCells = ((daysFromPrevMonth + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          DateTime date;
          bool isCurrentMonth;

          if (index < daysFromPrevMonth) {
            date = DateTime(
              previousMonth.year,
              previousMonth.month,
              previousMonth.day - daysFromPrevMonth + index + 1,
            );
            isCurrentMonth = false;
          } else if (index >= daysFromPrevMonth + daysInMonth) {
            date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month + 1,
              index - daysFromPrevMonth - daysInMonth + 1,
            );
            isCurrentMonth = false;
          } else {
            date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              index - daysFromPrevMonth + 1,
            );
            isCurrentMonth = true;
          }

          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          final isSelected =
              _selectedDate != null &&
              date.year == _selectedDate!.year &&
              date.month == _selectedDate!.month &&
              date.day == _selectedDate!.day;
          final taskCount = _getTaskCountForDate(tasks, date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isToday
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.primary, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                          ? null
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (taskCount > 0)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayTasks(List<TaskEntity> tasks, List categories) {
    if (_selectedDate == null) {
      return Center(
        child: Text(
          'Select a date to view tasks',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final dayTasks = _getTasksForDate(tasks, _selectedDate!);

    if (dayTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No tasks for ${DateFormat('MMM d').format(_selectedDate!)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          DateFormat('EEEE, MMMM d').format(_selectedDate!),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...dayTasks.map((task) {
          final category = categories
              .where((c) => c.id == task.categoryId)
              .firstOrNull;
          return TaskCard(
            task: task,
            categoryName: category?.name,
            categoryColor: category?.color,
            onToggleComplete: () {
              if (task.status == TaskStatus.completed) {
                ref.read(taskListProvider.notifier).uncompleteTask(task.id!);
              } else {
                ref.read(taskListProvider.notifier).completeTask(task.id!);
              }
            },
          );
        }),
      ],
    );
  }

  int _getTaskCountForDate(List<TaskEntity> tasks, DateTime date) {
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).length;
  }

  List<TaskEntity> _getTasksForDate(List<TaskEntity> tasks, DateTime date) {
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).toList();
  }
}
