import 'package:task_manager/features/projects/domain/entities/project_entity.dart';
import 'package:task_manager/features/projects/domain/repositories/project_repository.dart';

class UpdateProjectUseCase {
  final ProjectRepository _repository;

  UpdateProjectUseCase(this._repository);

  Future<ProjectEntity> execute({
    required String projectId,
    required String name,
    required String description,
    required ProjectStatus status,
    required ProjectPriority priority,
    DateTime? dueDate,
  }) {
    return _repository.updateProject(
      projectId: projectId,
      name: name,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );
  }
}