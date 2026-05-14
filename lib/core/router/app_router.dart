import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/core/widgets/app_bottom_navbar.dart';
import 'package:task_manager/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager/features/auth/presentation/pages/profile_page.dart';
import 'package:task_manager/features/auth/presentation/pages/settings_page.dart';
import 'package:task_manager/features/auth/presentation/pages/splash_page.dart';
import 'package:task_manager/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:task_manager/features/members/presentation/pages/pending_invites_page.dart';
import 'package:task_manager/features/notifications/presentation/pages/notifications_page.dart';
import 'package:task_manager/features/projects/presentation/pages/project_detail_page.dart';
import 'package:task_manager/features/projects/presentation/pages/projects_page.dart';
import 'package:task_manager/features/tasks/presentation/pages/task_details_page.dart';
import 'package:task_manager/features/tasks/presentation/pages/task_list_page.dart';
import 'package:task_manager/features/auth/presentation/pages/register_page.dart';
import 'package:task_manager/features/members/presentation/pages/manage_workspace_page.dart';
import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';
import 'package:task_manager/features/workspace/presentation/pages/workspace_detail_page.dart';
import 'package:task_manager/features/workspace/presentation/pages/workspace_list_page.dart';
import 'package:flutter/services.dart';
// import 'package:task_manager/features/members/presentation/pages/pending_invites_page.dart';

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
    // final isAuthPage = currentPath == '/login' ||
    //     currentPath == '/register' ||
    //     currentPath == '/';

    // Always let splash show — it handles its own navigation
    if (currentPath == '/') return null;

    // Pages that don't require login
    final isAuthPage = currentPath == '/login' || currentPath == '/register';

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
    GoRoute(
      path: '/workspace',
      name: 'workspace',
      builder: (context, state) => const ManageWorkspacePage(),
    ),
    GoRoute(
      path: '/workspaces',
      name: 'workspace-list',
      builder: (context, state) => const WorkspaceListPage(),
    ),
    GoRoute(
      path: '/workspace/:id',
      name: 'workspace-detail',
      builder: (context, state) {
        final workspace = state.extra as WorkspaceEntity;
        return WorkspaceDetailPage(workspace: workspace);
      },
    ),
    GoRoute(
      path: '/invites',
      name: 'invites',
      builder: (context, state) => const PendingInvitesPage(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsPage(),
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

    final isOnDashboard = location.startsWith('/dashboard');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If not on dashboard — go to dashboard
        if (!isOnDashboard) {
          context.go('/dashboard');
          return;
        }

        // If on dashboard — show exit confirmation
        // If on dashboard — show exit confirmation
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              insetPadding: EdgeInsets.all(10),
              backgroundColor: cs.surface,
              surfaceTintColor:
                  cs.surfaceTint, // Adds that nice M3 elevation tint
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  15,
                ), // Softer, more modern corners
              ),
              icon: Icon(Icons.logout_rounded, color: cs.error, size: 32),
              title: Text(
                'Exit Application',
                style: tt.headlineSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to leave?',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              actions: [
                Row(
                  children: [
                    // Use Expanded on both to ensure they take up 50% of the width each
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cs.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Matching the exit button
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ), // Taller for better touch targets
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Stay',
                          style: TextStyle(
                            color: cs.outlineVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ), // Controlled spacing between them
                    Expanded(
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.errorContainer,
                          foregroundColor: cs.onErrorContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => SystemNavigator.pop(),
                        child: const Text(
                          'Exit App',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        if (shouldExit == true) {
          // Actually exit the app
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
