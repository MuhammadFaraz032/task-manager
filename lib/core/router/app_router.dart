import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:task_manager/features/auth/presentation/pages/register_page.dart';

// LEARNING: GoRouter listens to Firebase auth state stream.
// Whenever auth state changes (login/logout) the router
// automatically re-evaluates the redirect and navigates
// the user to the correct screen.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  // LEARNING: refreshListenable tells GoRouter to re-run
  // the redirect function whenever Firebase auth state changes.
  // Without this the redirect only runs once at app start.
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

  // LEARNING: redirect runs before every navigation.
  // Return a path to redirect, return null to allow navigation.
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final currentPath = state.uri.toString();

    // Pages that don't require login
    final isAuthPage = currentPath == '/login' ||
        currentPath == '/register' ||
        currentPath == '/';

    // LEARNING: If not logged in and trying to access
    // a protected page → send to login
    if (!isLoggedIn && !isAuthPage) {
      return '/login';
    }

    // LEARNING: If already logged in and trying to access
    // login/register/splash → send to dashboard
    if (isLoggedIn && isAuthPage) {
      return '/dashboard';
    }

    // null means "allow navigation, no redirect needed"
    return null;
  },

  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
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
    GoRoute(
      path: '/project/:id',
      name: 'project-detail',
      builder: (context, state) {
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

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: const TextStyle(fontSize: 16),
      ),
    ),
  ),
);

// LEARNING: GoRouterRefreshStream converts a Stream into
// a Listenable that GoRouter can listen to.
// Firebase authStateChanges() is a Stream — every time
// user logs in or out it emits a new value.
// GoRouter sees the change and re-runs the redirect.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Listen to the stream and notify GoRouter
    // whenever it emits a new value
    stream.listen((_) => notifyListeners());
  }
}

// ─────────────────────────────────────────────────────────
// APP SHELL — unchanged
// ─────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

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
    final location = GoRouterState.of(context).uri.toString();
    _currentIndex = _routes.indexWhere((r) => location.startsWith(r));
    if (_currentIndex == -1) _currentIndex = 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
// ```

// ---

// ## What Changed
// ```
// Added:
// ├── refreshListenable → GoRouterRefreshStream
// │   → watches Firebase auth state
// │   → re-runs redirect on login/logout

// ├── redirect function
// │   → not logged in + protected page → /login
// │   → logged in + auth page → /dashboard
// │   → otherwise → null (allow)

// └── GoRouterRefreshStream class
//     → converts Firebase Stream to Listenable
// ```

// Now test these flows:
// ```
// 1. App open while logged out → should go to /login
// 2. App open while logged in  → should skip login → /dashboard
// 3. After logout              → should go to /login automatically
// 4. Try typing /dashboard URL → should redirect to /login