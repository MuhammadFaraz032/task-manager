import 'package:equatable/equatable.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TasksLoadRequested extends TaskEvent {
  final String workspaceId;
  final String? projectId;

  const TasksLoadRequested({
    required this.workspaceId,
    this.projectId,
  });

  @override
  List<Object?> get props => [workspaceId, projectId];
}

class TaskCreateRequested extends TaskEvent {
  final String title;
  final String description;
  final String workspaceId;
  final String createdBy;
  final String? projectId;
  final TaskPriority priority;
  final DateTime? dueDate;
  final List<ChecklistItem> checklist;

  const TaskCreateRequested({
    required this.title,
    required this.description,
    required this.workspaceId,
    required this.createdBy,
    this.projectId,
    required this.priority,
    this.dueDate,
    required this.checklist,
  });

  @override
  List<Object?> get props => [title, workspaceId, createdBy];
}

class TaskUpdateRequested extends TaskEvent {
  final String taskId;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final List<ChecklistItem> checklist;

  const TaskUpdateRequested({
    required this.taskId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.checklist,
  });

  @override
  List<Object?> get props => [taskId];
}

class TaskToggleRequested extends TaskEvent {
  final String taskId;
  final String completedBy;

  const TaskToggleRequested({
    required this.taskId,
    required this.completedBy,
  });

  @override
  List<Object?> get props => [taskId, completedBy];
}

class TaskDeleteRequested extends TaskEvent {
  final String taskId;
  final String deletedBy;

  const TaskDeleteRequested({
    required this.taskId,
    required this.deletedBy,
  });

  @override
  List<Object?> get props => [taskId, deletedBy];
}