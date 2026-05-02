import 'package:task_manager/features/workspace/domain/repositories/workspace_repository.dart';

class SetActiveWorkspaceUseCase {
  final WorkspaceRepository _repository;

  SetActiveWorkspaceUseCase(this._repository);

  Future<void> execute({
    required String userId,
    required String workspaceId,
  }) {
    return _repository.setActiveWorkspace(
      userId: userId,
      workspaceId: workspaceId,
    );
  }
}