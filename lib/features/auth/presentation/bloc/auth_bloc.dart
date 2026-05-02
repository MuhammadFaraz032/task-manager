import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/register_usecase.dart';
import 'package:task_manager/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:task_manager/features/workspace/domain/usecases/create_workspace_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final CreateWorkspaceUseCase _createWorkspaceUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required CreateWorkspaceUseCase createWorkspaceUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _createWorkspaceUseCase = createWorkspaceUseCase,
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
      emit(AuthAuthenticated(user, activeWorkspaceId: user.activeWorkspaceId));
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
      final user = await _loginUseCase.execute(
        email: event.email,
        password: event.password,
      );

      // Save FCM token after login
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': fcmToken});
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': newToken});
      });

      // Pass activeWorkspaceId so WorkspaceCubit loads the right workspace
      emit(AuthAuthenticated(user, activeWorkspaceId: user.activeWorkspaceId));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _registerUseCase.execute(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      );

      // Create workspace — also calls addWorkspaceToUser internally
      // so workspaces[] array is populated from the start
      await _createWorkspaceUseCase.execute(
        name: "${user.fullName}'s Workspace",
        ownerId: user.uid,
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
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
        // Save FCM token on app restart too
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'fcmToken': fcmToken});
        }

        // Pass activeWorkspaceId so WorkspaceCubit loads the right workspace
        emit(AuthAuthenticated(user, activeWorkspaceId: user.activeWorkspaceId));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
}