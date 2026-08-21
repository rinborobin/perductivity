import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/database/database.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_list_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: tasksState.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return _buildEmptyState();
          }

          final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
          final pending = tasks.where((t) => t.status == TaskStatus.todo).length;
          final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
          final archived = tasks.where((t) => t.status == TaskStatus.archived).length;
          final total = tasks.length;
          final completionRate = total > 0 ? (completed / total * 100).round() : 0;

          final weekData = _getWeeklyData(tasks);
          final priorityData = _getPriorityData(tasks);

          return RefreshIndicator(
            onRefresh: () => ref.read(taskListProvider.notifier).loadTasks(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _buildCompletionRateCard(completionRate, completed, total),
                const SizedBox(height: AppSpacing.md),
                _buildStatusBreakdown(completed, pending, inProgress, archived),
                const SizedBox(height: AppSpacing.md),
                _buildWeeklyProgressCard(weekData),
                const SizedBox(height: AppSpacing.md),
                _buildPriorityBreakdown(priorityData),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: AppColors.lightTextDisabled),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No data yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete some tasks to see statistics',
            style: TextStyle(color: AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateCard(int rate, int completed, int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Text(
              'Completion Rate',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: rate / 100,
                      strokeWidth: 10,
                      backgroundColor: AppColors.lightSurfaceVariant,
                      color: AppColors.primary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$rate%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$completed of $total tasks completed',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown(int completed, int pending, int inProgress, int archived) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            _StatusRow(label: 'Completed', count: completed, color: AppColors.success, icon: Icons.check_circle),
            _StatusRow(label: 'Pending', count: pending, color: AppColors.warning, icon: Icons.pending),
            _StatusRow(label: 'In Progress', count: inProgress, color: AppColors.info, icon: Icons.play_circle),
            _StatusRow(label: 'Archived', count: archived, color: AppColors.lightTextDisabled, icon: Icons.archive),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard(Map<String, int> weekData) {
    final maxValue = weekData.values.fold<int>(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weekData.entries.map((entry) {
                  final height = maxValue > 0 ? (entry.value / maxValue) * 120 : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.value}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height.clamp(4.0, 120.0),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBreakdown(Map<TaskPriority, int> data) {
    final total = data.values.fold<int>(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By Priority',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            _PriorityRow(
              label: 'High',
              count: data[TaskPriority.high] ?? 0,
              total: total,
              color: AppColors.error,
            ),
            _PriorityRow(
              label: 'Medium',
              count: data[TaskPriority.medium] ?? 0,
              total: total,
              color: AppColors.warning,
            ),
            _PriorityRow(
              label: 'Low',
              count: data[TaskPriority.low] ?? 0,
              total: total,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _getWeeklyData(List<TaskEntity> tasks) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final data = <String, int>{};

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final count = tasks.where((t) {
        if (t.completedAt == null) return false;
        return t.completedAt!.year == date.year &&
            t.completedAt!.month == date.month &&
            t.completedAt!.day == date.day;
      }).length;
      data[days[i]] = count;
    }

    return data;
  }

  Map<TaskPriority, int> _getPriorityData(List<TaskEntity> tasks) {
    final data = <TaskPriority, int>{};
    for (final priority in TaskPriority.values) {
      data[priority] = tasks.where((t) => t.priority == priority).length;
    }
    return data;
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _PriorityRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
          Text('$count'),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.lightSurfaceVariant,
                color: color,
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
