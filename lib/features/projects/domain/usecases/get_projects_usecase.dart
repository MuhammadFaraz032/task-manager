import 'package:task_manager/features/projects/domain/entities/project_entity.dart';
import 'package:task_manager/features/projects/domain/repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository _repository;

  GetProjectsUseCase(this._repository);

  Stream<List<ProjectEntity>> execute({required String workspaceId}) {
    return _repository.getProjects(workspaceId: workspaceId);
  }
}