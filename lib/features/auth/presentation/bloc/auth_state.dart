import 'package:equatable/equatable.dart';
import 'package:task_manager/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// App just started — checking if user is logged in
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Checking auth state — show splash/loading
class AuthLoading extends AuthState {
  const AuthLoading();
}

// User is logged in
// User is logged in
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final String? activeWorkspaceId;

  const AuthAuthenticated(this.user, {this.activeWorkspaceId});

  @override
  List<Object?> get props => [user, activeWorkspaceId];
}

// User is not logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// Something went wrong
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Add this state to existing auth_state.dart
class AuthProfileUpdated extends AuthState {
  final UserEntity user;
  const AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}