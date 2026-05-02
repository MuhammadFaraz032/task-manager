import 'package:equatable/equatable.dart';
import 'package:task_manager/features/workspace/domain/entities/workspace_entity.dart';

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();
}

class WorkspaceLoading extends WorkspaceState {
  const WorkspaceLoading();
}

class WorkspaceLoaded extends WorkspaceState {
  final WorkspaceEntity workspace;
  final List<WorkspaceEntity> allWorkspaces;

  const WorkspaceLoaded({
    required this.workspace,
    required this.allWorkspaces,
  });

  @override
  List<Object?> get props => [workspace, allWorkspaces];
}

class WorkspaceError extends WorkspaceState {
  final String message;
  const WorkspaceError(this.message);

  @override
  List<Object?> get props => [message];
}