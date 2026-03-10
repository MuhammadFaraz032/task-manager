import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/router/app_router.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';
import 'package:task_manager/core/theme/theme_state.dart';
import 'package:task_manager/core/theme/themecolors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Task Manager',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: state.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          // LEARNING: MaterialApp.router replaces MaterialApp
          // when using go_router. Instead of 'home:', we pass
          // routerConfig: which takes our GoRouter instance.
          routerConfig: appRouter,
        );
      },
    );
  }
}