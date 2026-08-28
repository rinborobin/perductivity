import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/tasks/presentation/screens/tasks_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/categories/presentation/screens/categories_screen.dart';
import '../shared/widgets/app_navigation_dock.dart';
import '../features/moodle/presentation/screens/moodle_settings_screen.dart';
import '../features/planner/presentation/screens/ai_planner_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TasksScreen()),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CalendarScreen()),
        ),
        GoRoute(
          path: '/statistics',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StatisticsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
          routes: [
            GoRoute(
              path: 'categories',
              builder: (context, state) => const CategoriesScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings/moodle',
      builder: (context, state) => const MoodleSettingsScreen(),
    ),
    GoRoute(
      path: '/planner',
      builder: (context, state) => const AiPlannerScreen(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/statistics')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/tasks');
        break;
      case 2:
        context.go('/calendar');
        break;
      case 3:
        context.go('/statistics');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppNavigationDock(
        selectedIndex: _calculateSelectedIndex(context),
        onSelected: (index) => _onItemTapped(context, index),
      ),
    );
  }
}
