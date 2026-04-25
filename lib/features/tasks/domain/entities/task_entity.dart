import 'package:equatable/equatable.dart';

enum TaskPriority { none, low, medium, high }

enum TaskStatus { todo, inProgress, completed }

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String workspaceId;
  final String? projectId;
  final String createdBy;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final List<ChecklistItem> checklist;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? completedBy;
  final bool isDeleted;
  final String? assignedTo;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.workspaceId,
    this.projectId,
    required this.createdBy,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.checklist,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.completedBy,
    this.isDeleted = false,
    this.assignedTo,
  });

  bool get isCompleted => status == TaskStatus.completed;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    workspaceId,
    projectId,
    createdBy,
    priority,
    status,
    dueDate,
    checklist,
    createdAt,
    updatedAt,
    completedAt,
    completedBy,
    isDeleted,
    assignedTo,
  ];
}

class ChecklistItem extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [id, title, isCompleted];
}
