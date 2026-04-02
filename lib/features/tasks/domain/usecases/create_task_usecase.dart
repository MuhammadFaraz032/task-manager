import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository _repository;

  CreateTaskUseCase(this._repository);

  Future<TaskEntity> execute({
    required String title,
    required String description,
    required String workspaceId,
    required String createdBy,
    String? projectId,
    required TaskPriority priority,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  }) {
    return _repository.createTask(
      title: title,
      description: description,
      workspaceId: workspaceId,
      createdBy: createdBy,
      projectId: projectId,
      priority: priority,
      dueDate: dueDate,
      checklist: checklist,
    );
  }
}