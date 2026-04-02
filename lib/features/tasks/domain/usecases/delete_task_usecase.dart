import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  Future<void> execute({
    required String taskId,
    required String deletedBy,
  }) {
    return _repository.deleteTask(
      taskId: taskId,
      deletedBy: deletedBy,
    );
  }
}