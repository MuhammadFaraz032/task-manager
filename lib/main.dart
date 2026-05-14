import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/core/di/injection_container.dart';
import 'package:task_manager/core/router/app_router.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';
import 'package:task_manager/core/theme/theme_state.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_bloc.dart';
import 'package:task_manager/features/members/presentation/bloc/invite_state.dart';
import 'package:task_manager/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/firebase_options.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
import 'package:task_manager/features/members/presentation/bloc/member_bloc.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_state.dart';

// Handles notifications when app is completely killed
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

// Called when user taps a notification (background or killed state)
Future<void> _handleNotificationTap(RemoteMessage message) async {
  final taskId = message.data['taskId'];
  final workspaceId = message.data['workspaceId'];

  if (taskId == null) return;

  final context = navigatorKey.currentContext;
  if (context == null) return;

  // Switch workspace if notification belongs to a different one
  if (workspaceId != null) {
    final workspaceCubit = getIt<WorkspaceCubit>();
    final workspaceState = workspaceCubit.state;
    final currentId = workspaceState is WorkspaceLoaded
        ? workspaceState.workspace.id
        : null;

    if (currentId != workspaceId) {
      final authState = getIt<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        await workspaceCubit.switchWorkspace(
          userId: authState.user.uid,
          workspaceId: workspaceId,
        );
      }
    }
  }

  // Navigate to task
  appRouter.push('/task/$taskId');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Global navigator key so we can navigate from outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup local notifications channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'task_manager_channel',
    'Task Manager Notifications',
    description: 'Notifications for task assignments, completions and comments',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Request permission on Android 13+
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await setupDependencies();

  // Handle foreground notifications
  // Handle background tap — app was minimized, user taps notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationTap(message);
  });

  // Handle killed app — check if launched from a notification
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // Delay to let the app and blocs fully initialize first
    Future.delayed(const Duration(seconds: 2), () {
      _handleNotificationTap(initialMessage);
    });
  }

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_manager_channel',
            'Task Manager Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
        BlocProvider(create: (_) => getIt<WorkspaceCubit>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<ProjectBloc>()),
        BlocProvider(create: (_) => getIt<TaskBloc>()),
        BlocProvider(create: (_) => getIt<MemberBloc>()),
        BlocProvider(create: (_) => getIt<InviteBloc>()),
        BlocProvider(create: (_) => getIt<NotificationBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              current is AuthAuthenticated && previous is! AuthAuthenticated,
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.read<WorkspaceCubit>().loadWorkspace(
                ownerId: state.user.uid,
                activeWorkspaceId: state.user.activeWorkspaceId,
              );
            }
          },
        ),
        BlocListener<InviteBloc, InviteState>(
          listener: (context, state) {
            if (state is InviteAccepted) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<WorkspaceCubit>().loadWorkspace(
                  ownerId: authState.user.uid,
                  activeWorkspaceId: authState.user.activeWorkspaceId,
                );
              }
            }
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Task Manager',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
            // Needed to navigate from outside widget tree
            // (notification taps in background/killed state)
          );
        },
      ),
    );
  }
}
