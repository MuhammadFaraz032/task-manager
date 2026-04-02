import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  Future<TaskEntity> execute({
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  }) {
    return _repository.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      checklist: checklist,
    );
  }
}