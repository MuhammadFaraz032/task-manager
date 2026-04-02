import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

// LEARNING: ToggleTask is a separate UseCase
// because toggling completion is a distinct
// business operation from general update
// It also updates project task counts
class ToggleTaskUseCase {
  final TaskRepository _repository;

  ToggleTaskUseCase(this._repository);

  Future<TaskEntity> execute({
    required String taskId,
    required String completedBy,
  }) {
    return _repository.toggleTask(
      taskId: taskId,
      completedBy: completedBy,
    );
  }
}