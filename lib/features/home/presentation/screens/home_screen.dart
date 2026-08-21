import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_list_provider.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../categories/presentation/providers/category_list_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskListProvider);
    final categoriesState = ref.watch(categoryListProvider);

    return Scaffold(
      body: SafeArea(
        child: tasksState.when(
          data: (tasks) {
            final categories = categoriesState.valueOrNull ?? [];
            final now = DateTime.now();
            final todayTasks = _getTodayTasks(tasks, now);
            final upcomingTasks = _getUpcomingTasks(tasks, now);
            final completedToday = _getCompletedToday(tasks, now);
            final pendingCount = tasks.where((t) => t.status != TaskStatus.completed && t.status != TaskStatus.archived).length;

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(taskListProvider.notifier).loadTasks();
                await ref.read(categoryListProvider.notifier).loadCategories();
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _buildHeader(now),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatsCards(pendingCount, completedToday.length, todayTasks.length),
                  const SizedBox(height: AppSpacing.lg),
                  if (todayTasks.isNotEmpty) ...[
                    _buildSectionHeader("Today's Tasks", todayTasks.length.toString()),
                    const SizedBox(height: AppSpacing.sm),
                    ...todayTasks.take(5).map((task) {
                      final category = categories.where((c) => c.id == task.categoryId).firstOrNull;
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
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (upcomingTasks.isNotEmpty) ...[
                    _buildSectionHeader('Upcoming', upcomingTasks.length.toString()),
                    const SizedBox(height: AppSpacing.sm),
                    ...upcomingTasks.take(5).map((task) {
                      final category = categories.where((c) => c.id == task.categoryId).firstOrNull;
                      return TaskCard(
                        task: task,
                        categoryName: category?.name,
                        categoryColor: category?.color,
                        onToggleComplete: () {
                          ref.read(taskListProvider.notifier).completeTask(task.id!);
                        },
                      );
                    }),
                  ],
                  if (tasks.isEmpty) _buildEmptyState(),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime now) {
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          DateFormat('EEEE, MMMM d').format(now),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(int pending, int completedToday, int todayTotal) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Pending',
            value: pending.toString(),
            icon: Icons.pending_actions,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Done Today',
            value: completedToday.toString(),
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Today',
            value: todayTotal.toString(),
            icon: Icons.today,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 64,
              color: AppColors.lightTextDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'All caught up!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No tasks for today',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  List<TaskEntity> _getTodayTasks(List<TaskEntity> tasks, DateTime now) {
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return tasks.where((t) {
      if (t.status == TaskStatus.archived) return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(startOfDay) && t.dueDate!.isBefore(endOfDay);
    }).toList();
  }

  List<TaskEntity> _getUpcomingTasks(List<TaskEntity> tasks, DateTime now) {
    final endOfToday = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    return tasks.where((t) {
      if (t.status == TaskStatus.completed || t.status == TaskStatus.archived) return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(endOfToday);
    }).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  List<TaskEntity> _getCompletedToday(List<TaskEntity> tasks, DateTime now) {
    final startOfDay = DateTime(now.year, now.month, now.day);

    return tasks.where((t) {
      if (t.status != TaskStatus.completed) return false;
      if (t.completedAt == null) return false;
      return t.completedAt!.isAfter(startOfDay);
    }).toList();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
