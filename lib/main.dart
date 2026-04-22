import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/di/injection_container.dart';
import 'package:task_manager/core/router/app_router.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';
import 'package:task_manager/core/theme/theme_state.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:task_manager/firebase_options.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
// import 'firebase_options.dart';

void main() async {
  // LEARNING: WidgetsFlutterBinding.ensureInitialized() must be
  // called before any async work in main(). It initializes the
  // Flutter engine binding so plugins like Firebase can be set up
  // before runApp() is called.
  WidgetsFlutterBinding.ensureInitialized();

  // LEARNING: Firebase.initializeApp() reads the google-services.json
  // file (via firebase_options.dart) and connects the app to your
  // Firebase project. Must be awaited before anything else runs.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // LEARNING: setupDependencies() must be called after
  // Firebase.initializeApp() because some dependencies
  // like FirebaseAuth and FirebaseFirestore need Firebase
  // to be initialized before they can be instantiated
  await setupDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
        BlocProvider(create: (_) => getIt<WorkspaceCubit>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<ProjectBloc>()),
        BlocProvider(create: (_) => getIt<TaskBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthAuthenticated && previous is! AuthAuthenticated,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // print('🟡 MyApp listener — loading workspace for: ${state.user.uid}');
          context.read<WorkspaceCubit>().loadWorkspace(ownerId: state.user.uid);
        }
      },
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Task Manager',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
