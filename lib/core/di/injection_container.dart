import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';

// Auth
import 'package:task_manager/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_manager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/register_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';

// Workspace
import 'package:task_manager/features/workspace/data/datasources/workspace_remote_datasource.dart';
import 'package:task_manager/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:task_manager/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:task_manager/features/workspace/domain/usecases/create_workspace_usecase.dart';
import 'package:task_manager/features/workspace/domain/usecases/get_workspace_usecase.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ─────────────────────────────────────────────
  // EXTERNAL — Firebase instances
  // LEARNING: These are registered as singletons
  // because we need exactly one connection to
  // Firebase Auth and Firestore throughout the app
  // ─────────────────────────────────────────────
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton(() => ThemeCubit());
  // ─────────────────────────────────────────────
  // AUTH FEATURE
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: getIt(), firestore: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateUserUseCase(getIt())); // Add use case
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));

  // BLoC — Factory because it has screen state
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
      createWorkspaceUseCase: getIt(),
      getWorkspaceUseCase: getIt(),
      updateUserUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
    ),
  );

  // ─────────────────────────────────────────────
  // WORKSPACE FEATURE
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerLazySingleton<WorkspaceRemoteDataSource>(
    () => WorkspaceRemoteDataSourceImpl(firestore: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(dataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => CreateWorkspaceUseCase(getIt()));
  getIt.registerLazySingleton(() => GetWorkspaceUseCase(getIt()));

  // Cubit — Singleton because one workspace per session
  getIt.registerLazySingleton(
    () => WorkspaceCubit(
      createWorkspaceUseCase: getIt(),
      getWorkspaceUseCase: getIt(),
    ),
  );
}
