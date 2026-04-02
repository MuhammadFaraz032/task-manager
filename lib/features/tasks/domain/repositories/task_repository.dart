import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> getTasks({
    required String workspaceId,
    String? projectId,
  });

  Future<TaskEntity> createTask({
    required String title,
    required String description,
    required String workspaceId,
    required String createdBy,
    String? projectId,
    required TaskPriority priority,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  });

  Future<TaskEntity> updateTask({
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  });

  Future<TaskEntity> toggleTask({
    required String taskId,
    required String completedBy,
  });

  Future<void> deleteTask({
    required String taskId,
    required String deletedBy,
  });
}