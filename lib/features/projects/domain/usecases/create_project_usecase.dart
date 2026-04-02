import 'package:task_manager/features/projects/domain/entities/project_entity.dart';
import 'package:task_manager/features/projects/domain/repositories/project_repository.dart';

class CreateProjectUseCase {
  final ProjectRepository _repository;

  CreateProjectUseCase(this._repository);

  Future<ProjectEntity> execute({
    required String name,
    required String description,
    required String workspaceId,
    required String createdBy,
    required ProjectPriority priority,
    DateTime? dueDate,
  }) {
    return _repository.createProject(
      name: name,
      description: description,
      workspaceId: workspaceId,
      createdBy: createdBy,
      priority: priority,
      dueDate: dueDate,
    );
  }
}