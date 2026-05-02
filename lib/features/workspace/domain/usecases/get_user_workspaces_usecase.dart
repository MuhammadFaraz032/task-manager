import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';
import 'package:task_manager/features/workspace/domain/repositories/workspace_repository.dart';

class GetUserWorkspacesUseCase {
  final WorkspaceRepository _repository;

  GetUserWorkspacesUseCase(this._repository);

  Future<List<WorkspaceEntity>> execute({required String userId}) {
    return _repository.getUserWorkspaces(userId: userId);
  }
}