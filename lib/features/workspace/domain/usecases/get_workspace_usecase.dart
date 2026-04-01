import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';
import 'package:task_manager/features/workspace/domain/repositories/workspace_repository.dart';

class GetWorkspaceUseCase {
  final WorkspaceRepository _repository;

  GetWorkspaceUseCase(this._repository);

  Future<WorkspaceEntity?> execute({required String ownerId}) {
    return _repository.getWorkspace(ownerId: ownerId);
  }
}