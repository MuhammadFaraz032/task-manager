import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Check if user is already logged in on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// User submits login form
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// User submits register form
class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, password];
}

// User taps logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// Add this event to existing auth_event.dart
class AuthUpdateProfileRequested extends AuthEvent {
  final String uid;
  final String fullName;
  final String jobTitle;

  const AuthUpdateProfileRequested({
    required this.uid,
    required this.fullName,
    required this.jobTitle,
  });

  @override
  List<Object?> get props => [uid, fullName, jobTitle];
}
