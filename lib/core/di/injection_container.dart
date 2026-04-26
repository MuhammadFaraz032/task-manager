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
import 'package:task_manager/features/members/presentation/bloc/invite_bloc.dart';
import 'package:task_manager/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:task_manager/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/tasks/domain/usecases/add_comment_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/delete_comment_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/get_comments_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/toggle_task_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:task_manager/features/tasks/presentation/bloc/comment_bloc.dart';
import 'package:task_manager/features/tasks/presentation/bloc/task_bloc.dart';

// Workspace
import 'package:task_manager/features/workspace/data/datasources/workspace_remote_datasource.dart';
import 'package:task_manager/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:task_manager/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:task_manager/features/workspace/domain/usecases/create_workspace_usecase.dart';
import 'package:task_manager/features/workspace/domain/usecases/get_workspace_usecase.dart';
import 'package:task_manager/features/workspace/presentation/cubit/workspace_cubit.dart';

// Add imports
import 'package:task_manager/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:task_manager/features/projects/data/repositories/project_repository_impl.dart';
import 'package:task_manager/features/projects/domain/repositories/project_repository.dart';
import 'package:task_manager/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:task_manager/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:task_manager/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:task_manager/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:task_manager/features/projects/presentation/bloc/project_bloc.dart';
// Members
import 'package:task_manager/features/members/data/datasources/member_remote_datasource.dart';
import 'package:task_manager/features/members/data/repositories/member_repository_impl.dart';
import 'package:task_manager/features/members/domain/repositories/member_repository.dart';
import 'package:task_manager/features/members/domain/usecases/invite_user_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/accept_invite_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/decline_invite_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/get_workspace_members_usecase.dart';
import 'package:task_manager/features/members/domain/usecases/get_pending_invites_usecase.dart';
import 'package:task_manager/features/members/presentation/bloc/member_bloc.dart';

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

  // ─────────────────────────────────────────────
  // PROJECTS FEATURE
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(firestore: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(dataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetProjectsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateProjectUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProjectUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteProjectUseCase(getIt()));

  // Bloc — Factory because it has screen state
  getIt.registerLazySingleton(
    () => ProjectBloc(
      getProjectsUseCase: getIt(),
      createProjectUseCase: getIt(),
      updateProjectUseCase: getIt(),
      deleteProjectUseCase: getIt(),
    ),
  );

  // ─────────────────────────────────────────────
  // TASKS FEATURE
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(firestore: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(dataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetTasksUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => ToggleTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteTaskUseCase(getIt()));

  // Bloc
  getIt.registerLazySingleton(
    () => TaskBloc(
      getTasksUseCase: getIt(),
      createTaskUseCase: getIt(),
      updateTaskUseCase: getIt(),
      toggleTaskUseCase: getIt(),
      deleteTaskUseCase: getIt(),
    ),
  );

  // ─────────────────────────────────────────────
  // MEMBERS FEATURE
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerLazySingleton<MemberRemoteDataSource>(
    () => MemberRemoteDataSourceImpl(firestore: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<MemberRepository>(
    () => MemberRepositoryImpl(dataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => InviteUserUseCase(getIt()));
  getIt.registerLazySingleton(() => AcceptInviteUseCase(getIt()));
  getIt.registerLazySingleton(() => DeclineInviteUseCase(getIt()));
  getIt.registerLazySingleton(() => GetWorkspaceMembersUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPendingInvitesUseCase(getIt()));

  // BLoC — Factory because it has screen state
  getIt.registerFactory(() => MemberBloc(getWorkspaceMembersUseCase: getIt()));

  getIt.registerFactory(
    () => InviteBloc(
      getPendingInvitesUseCase: getIt(),
      inviteUserUseCase: getIt(),
      acceptInviteUseCase: getIt(),
      declineInviteUseCase: getIt(),
    ),
  );

  // ─────────────────────────────────────────────
  // COMMENTS FEATURE
  // ─────────────────────────────────────────────

  // Use Cases — LazySingleton because stateless
  getIt.registerLazySingleton(() => GetCommentsUseCase(getIt()));
  getIt.registerLazySingleton(() => AddCommentUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCommentUseCase(getIt()));

  // BLoC — Factory because scoped to task detail page
  getIt.registerFactory(
    () => CommentBloc(
      getCommentsUseCase: getIt(),
      addCommentUseCase: getIt(),
      deleteCommentUseCase: getIt(),
    ),
  );
}
