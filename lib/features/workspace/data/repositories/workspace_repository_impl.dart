import 'package:task_manager/features/workspace/data/datasources/workspace_remote_datasource.dart';
import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';
import 'package:task_manager/features/workspace/domain/repositories/workspace_repository.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceRemoteDataSource _dataSource;

  WorkspaceRepositoryImpl({required WorkspaceRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<WorkspaceEntity> createWorkspace({
    required String name,
    required String ownerId,
  }) {
    return _dataSource.createWorkspace(
      name: name,
      ownerId: ownerId,
    );
  }

  @override
  Future<WorkspaceEntity?> getWorkspace({
    required String ownerId,
  }) {
    return _dataSource.getWorkspace(ownerId: ownerId);
  }

  @override
  Future<void> updateWorkspaceId({
    required String userId,
    required String workspaceId,
  }) {
    return _dataSource.updateWorkspaceId(
      userId: userId,
      workspaceId: workspaceId,
    );
  }
}