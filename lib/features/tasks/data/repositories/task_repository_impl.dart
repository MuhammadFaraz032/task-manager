import 'package:task_manager/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';
import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _dataSource;

  TaskRepositoryImpl({required TaskRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<List<TaskEntity>> getTasks({
    required String workspaceId,
    String? projectId,
  }) {
    return _dataSource.getTasks(
      workspaceId: workspaceId,
      projectId: projectId,
    );
  }

  @override
  Future<TaskEntity> createTask({
    required String title,
    required String description,
    required String workspaceId,
    required String createdBy,
    String? projectId,
    required TaskPriority priority,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  }) {
    return _dataSource.createTask(
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

  @override
  Future<TaskEntity> updateTask({
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    required List<ChecklistItem> checklist,
  }) {
    return _dataSource.updateTask(
      taskId: taskId,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      checklist: checklist,
    );
  }

  @override
  Future<TaskEntity> toggleTask({
    required String taskId,
    required String completedBy,
  }) {
    return _dataSource.toggleTask(
      taskId: taskId,
      completedBy: completedBy,
    );
  }

  @override
  Future<void> deleteTask({
    required String taskId,
    required String deletedBy,
  }) {
    return _dataSource.deleteTask(
      taskId: taskId,
      deletedBy: deletedBy,
    );
  }
}