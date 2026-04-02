import 'package:task_manager/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:task_manager/features/projects/domain/entities/project_entity.dart';
import 'package:task_manager/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _dataSource;

  ProjectRepositoryImpl({required ProjectRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<List<ProjectEntity>> getProjects({
    required String workspaceId,
  }) {
    return _dataSource.getProjects(workspaceId: workspaceId);
  }

  @override
  Future<ProjectEntity> createProject({
    required String name,
    required String description,
    required String workspaceId,
    required String createdBy,
    required ProjectPriority priority,
    DateTime? dueDate,
  }) {
    return _dataSource.createProject(
      name: name,
      description: description,
      workspaceId: workspaceId,
      createdBy: createdBy,
      priority: priority,
      dueDate: dueDate,
    );
  }

  @override
  Future<ProjectEntity> updateProject({
    required String projectId,
    required String name,
    required String description,
    required ProjectStatus status,
    required ProjectPriority priority,
    DateTime? dueDate,
  }) {
    return _dataSource.updateProject(
      projectId: projectId,
      name: name,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );
  }

  @override
  Future<void> deleteProject({
    required String projectId,
    required String deletedBy,
  }) {
    return _dataSource.deleteProject(
      projectId: projectId,
      deletedBy: deletedBy,
    );
  }
}