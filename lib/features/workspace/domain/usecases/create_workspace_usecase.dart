import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';
import 'package:task_manager/features/workspace/domain/repositories/workspace_repository.dart';

class CreateWorkspaceUseCase {
  final WorkspaceRepository _repository;

  CreateWorkspaceUseCase(this._repository);

  Future<WorkspaceEntity> execute({
    required String name,
    required String ownerId,
  }) {
    return _repository.createWorkspace(
      name: name,
      ownerId: ownerId,
    );
  }
}