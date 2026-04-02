import 'package:task_manager/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectUseCase {
  final ProjectRepository _repository;

  DeleteProjectUseCase(this._repository);

  Future<void> execute({
    required String projectId,
    required String deletedBy,
  }) {
    return _repository.deleteProject(
      projectId: projectId,
      deletedBy: deletedBy,
    );
  }
}