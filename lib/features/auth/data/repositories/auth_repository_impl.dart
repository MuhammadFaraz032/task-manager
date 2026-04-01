import 'package:task_manager/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

// LEARNING: RepositoryImpl bridges domain and data layers
// Domain layer calls repository methods
// Repository calls datasource methods
// This separation means we can swap Firebase
// for any other backend without touching domain
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<UserEntity> login({required String email, required String password}) {
    return _dataSource.login(email: email, password: password);
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _dataSource.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return _dataSource.logout();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges;
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> updateUser({
    required String uid,
    required String fullName,
    required String jobTitle,
  }) {
    return _dataSource.updateUser(
      uid: uid,
      fullName: fullName,
      jobTitle: jobTitle,
    );
  }
}
