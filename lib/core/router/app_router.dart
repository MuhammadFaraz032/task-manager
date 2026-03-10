import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/widgets/app_bottom_navbar.dart';
import 'package:task_manager/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager/features/auth/presentation/pages/profile_page.dart';
import 'package:task_manager/features/auth/presentation/pages/settings_page.dart';
import 'package:task_manager/features/auth/presentation/pages/splash_page.dart';
import 'package:task_manager/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:task_manager/features/projects/presentation/pages/project_detail_page.dart';
import 'package:task_manager/features/projects/presentation/pages/projects_page.dart';
import 'package:task_manager/features/tasks/presentation/pages/task_details_page.dart';
import 'package:task_manager/features/tasks/presentation/pages/task_list_page.dart';

// LEARNING: GoRouter is the central navigation config for the app.
// Define it once at the top level and provide it to MaterialApp.router.
// Every route in the app lives here — no Navigator.push anywhere.
final GoRouter appRouter = GoRouter(
  // LEARNING: initialLocation is the first route the app opens.
  // This will later be replaced by a redirect based on auth state.
  initialLocation: '/',

  // LEARNING: routes is the list of all possible destinations.
  // GoRouter reads this list when context.go('/path') is called
  // and builds the matching widget.
  routes: [
    // ─────────────────────────────────────────────
    // SPLASH ROUTE
    // ─────────────────────────────────────────────
    GoRoute(
      path: '/',
      name: 'splash',
      // LEARNING: builder returns the widget for this route.
      // (context, state) — state carries route params if any.
      builder: (context, state) => const SplashScreen(),
    ),

    // ─────────────────────────────────────────────
    // LOGIN ROUTE
    // ─────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ─────────────────────────────────────────────
    // SHELL ROUTE — persistent bottom nav
    // LEARNING: ShellRoute wraps child routes inside a shared
    // shell widget. The shell (bottom nav + scaffold) stays
    // mounted while only the body content changes.
    // This is how you get a persistent bottom nav bar
    // without rebuilding it on every navigation.
    // ─────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardContent(),
        ),
        GoRoute(
          path: '/projects',
          name: 'projects',
          builder: (context, state) => const ProjectsScreen(),
        ),
        // GoRoute(
        //   path: '/tasks',
        //   name: 'tasks',
        //   builder: (context, state) => const ComingSoon(pageName: 'Tasks'),
        // ),
        GoRoute(
          path: '/tasks',
          name: 'tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // ─────────────────────────────────────────────
    // PROJECT DETAIL ROUTE — outside ShellRoute
    // LEARNING: ProjectDetail is outside ShellRoute intentionally.
    // Detail pages are full screen — no bottom nav visible.
    // If it were inside ShellRoute, the bottom nav would show
    // on the detail page which is wrong UX.
    // ─────────────────────────────────────────────
    GoRoute(
      path: '/project/:id',
      name: 'project-detail',
      builder: (context, state) {
        // LEARNING: pathParameters extracts the :id from the URL.
        // context.go('/project/abc123') → projectId = 'abc123'
        // This is how you pass data through routes.
        final projectId = state.pathParameters['id'] ?? '';
        return ProjectDetailScreen(projectId: projectId);
      },
    ),

    GoRoute(
      path: '/task/:id',
      name: 'task-detail',
      builder: (context, state) {
        final taskId = state.pathParameters['id'] ?? '';
        return TaskDetailPage(taskId: taskId);
      },
    ),
  ],

  // LEARNING: errorBuilder shows a fallback UI if the user
  // navigates to a route that doesn't exist.
  // Always add this — without it the app crashes on bad routes.
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: const TextStyle(fontSize: 16),
      ),
    ),
  ),
);

// ─────────────────────────────────────────────────────────
// APP SHELL
// LEARNING: AppShell is the persistent wrapper for all
// ShellRoute children. It holds the Scaffold + BottomNavBar.
// 'child' is whatever the current route's widget is —
// go_router injects it automatically.
// ─────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // LEARNING: We map each index to its route path.
  // When the user taps a nav item, we go to that path.
  // When the route changes, we find the matching index.
  static const List<String> _routes = [
    '/dashboard',
    '/projects',
    '/tasks',
    '/settings',
    '/profile',
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    // LEARNING: We sync _currentIndex with the actual current
    // route so the correct nav item is highlighted even when
    // navigation happens from outside the bottom nav
    // (e.g. context.go('/projects') from dashboard).
    final location = GoRouterState.of(context).uri.toString();
    _currentIndex = _routes.indexWhere((r) => location.startsWith(r));
    // indexWhere returns -1 if not found — fallback to 0
    if (_currentIndex == -1) _currentIndex = 0;

    return Scaffold(
      // LEARNING: 'child' is the current page widget injected
      // by go_router. AppShell doesn't need to know what it is —
      // it just displays it. This is the Shell pattern.
      body: widget.child,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
