import 'package:equatable/equatable.dart';
import 'package:task_manager/features/projects/domain/entities/project_entity.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class ProjectsLoadRequested extends ProjectEvent {
  final String workspaceId;
  const ProjectsLoadRequested({required this.workspaceId});

  @override
  List<Object?> get props => [workspaceId];
}

class ProjectCreateRequested extends ProjectEvent {
  final String name;
  final String description;
  final String workspaceId;
  final String createdBy;
  final ProjectPriority priority;
  final DateTime? dueDate;

  const ProjectCreateRequested({
    required this.name,
    required this.description,
    required this.workspaceId,
    required this.createdBy,
    required this.priority,
    this.dueDate,
  });

  @override
  List<Object?> get props => [name, description, workspaceId, createdBy];
}

class ProjectUpdateRequested extends ProjectEvent {
  final String projectId;
  final String name;
  final String description;
  final ProjectStatus status;
  final ProjectPriority priority;
  final DateTime? dueDate;

  const ProjectUpdateRequested({
    required this.projectId,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
  });

  @override
  List<Object?> get props => [projectId, name, description];
}

class ProjectDeleteRequested extends ProjectEvent {
  final String projectId;
  final String deletedBy;

  const ProjectDeleteRequested({
    required this.projectId,
    required this.deletedBy,
  });

  @override
  List<Object?> get props => [projectId, deletedBy];
}