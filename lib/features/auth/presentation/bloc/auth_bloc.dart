import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/register_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:task_manager/features/workspace/domain/usecases/get_workspace_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:task_manager/features/workspace/domain/usecases/create_workspace_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final CreateWorkspaceUseCase _createWorkspaceUseCase;
  final GetWorkspaceUseCase _getWorkspaceUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required CreateWorkspaceUseCase createWorkspaceUseCase,
    required GetWorkspaceUseCase getWorkspaceUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _createWorkspaceUseCase = createWorkspaceUseCase,
       _getWorkspaceUseCase = getWorkspaceUseCase,
       _updateUserUseCase = updateUserUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _updateUserUseCase.execute(
        uid: event.uid,
        fullName: event.fullName,
        jobTitle: event.jobTitle,
      );
      emit(AuthProfileUpdated(user));
      // LEARNING: Also emit AuthAuthenticated so the
      // rest of the app sees the updated user immediately
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // print('🔵 Login started: ${event.email}');
      final user = await _loginUseCase.execute(
        email: event.email,
        password: event.password,
      );
      // print('✅ Login success: ${user.uid}');

      // Load workspace — result stored in WorkspaceCubit
      // at app level via main.dart
      await _getWorkspaceUseCase.execute(ownerId: user.uid);
      // print('✅ Workspace loaded for: ${user.uid}');

      emit(AuthAuthenticated(user));
    } catch (e) {
      // print('❌ Login error: $e');
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // print('🔵 Register started: ${event.email}');
      final user = await _registerUseCase.execute(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      );
      // print('✅ Register success: ${user.uid}');

      // LEARNING: Create workspace immediately after register
      // inside the Bloc — not in the UI
      // This way it runs before any navigation happens
      await _createWorkspaceUseCase.execute(
        name: "${user.fullName}'s Workspace",
        ownerId: user.uid,
      );
      // print('✅ Workspace created for: ${user.uid}');

      emit(AuthAuthenticated(user));
    } catch (e) {
      // print('❌ Register error: $e');
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _logoutUseCase.execute();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _getCurrentUserUseCase.execute();
      if (user != null) {
        // print('✅ User already logged in: ${user.uid}');

        // LEARNING: Load workspace here too
        // because when user is already logged in
        // they skip the login flow entirely
        // so we must load workspace here
        await _getWorkspaceUseCase.execute(ownerId: user.uid);
        // print('✅ Workspace loaded for: ${user.uid}');

        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
}
