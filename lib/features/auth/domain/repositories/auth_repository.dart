import 'package:task_manager/features/auth/domain/entities/user_entity.dart';

// LEARNING: Abstract class defines the CONTRACT
// It says WHAT the repository can do
// but not HOW it does it
// The Impl class decides HOW
abstract class AuthRepository {
  
  // Returns UserEntity on success
  // Throws exception on failure
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout();

  // LEARNING: Stream means it continuously
  // emits values whenever auth state changes
  // null = logged out, UserEntity = logged in
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> updateUser({
    required String uid,
    required String fullName,
    required String jobTitle,
  });
}