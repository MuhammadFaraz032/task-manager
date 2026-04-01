import 'package:task_manager/features/auth/domain/entities/user_entity.dart';
import 'package:task_manager/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserUseCase {
  final AuthRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<UserEntity> execute({
    required String uid,
    required String fullName,
    required String jobTitle,
  }) {
    return _repository.updateUser(
      uid: uid,
      fullName: fullName,
      jobTitle: jobTitle,
    );
  }
}