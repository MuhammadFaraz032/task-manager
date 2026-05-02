import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';

abstract class WorkspaceRepository {
  Future<WorkspaceEntity> createWorkspace({
    required String name,
    required String ownerId,
  });

  Future<WorkspaceEntity?> getWorkspace({
    required String ownerId,
  });

  Future<void> updateWorkspaceId({
    required String userId,
    required String workspaceId,
  });

  Future<List<WorkspaceEntity>> getUserWorkspaces({
    required String userId,
  });

  Future<void> addWorkspaceToUser({
    required String userId,
    required String workspaceId,
  });

  Future<void> setActiveWorkspace({
    required String userId,
    required String workspaceId,
  });

}