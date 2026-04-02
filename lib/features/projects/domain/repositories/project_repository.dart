import 'package:task_manager/features/projects/domain/entities/project_entity.dart';

abstract class ProjectRepository {
  // LEARNING: Stream returns real time updates
  // whenever projects change in Firestore
  // the UI updates automatically
  Stream<List<ProjectEntity>> getProjects({
    required String workspaceId,
  });

  Future<ProjectEntity> createProject({
    required String name,
    required String description,
    required String workspaceId,
    required String createdBy,
    required ProjectPriority priority,
    DateTime? dueDate,
  });

  Future<ProjectEntity> updateProject({
    required String projectId,
    required String name,
    required String description,
    required ProjectStatus status,
    required ProjectPriority priority,
    DateTime? dueDate,
  });

  Future<void> deleteProject({
    required String projectId,
    required String deletedBy,
  });
}