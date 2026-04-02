import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository _repository;

  GetTasksUseCase(this._repository);

  Stream<List<TaskEntity>> execute({
    required String workspaceId,
    String? projectId,
  }) {
    return _repository.getTasks(
      workspaceId: workspaceId,
      projectId: projectId,
    );
  }
}