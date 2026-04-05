import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:task_manager/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:task_manager/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:task_manager/features/projects/domain/usecases/update_project_usecase.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;

  // LEARNING: StreamSubscription holds the Firestore
  // real time listener. We need to cancel it when
  // the bloc is closed to prevent memory leaks
  StreamSubscription? _projectsSubscription;

  ProjectBloc({
    required GetProjectsUseCase getProjectsUseCase,
    required CreateProjectUseCase createProjectUseCase,
    required UpdateProjectUseCase updateProjectUseCase,
    required DeleteProjectUseCase deleteProjectUseCase,
  }) : _getProjectsUseCase = getProjectsUseCase,
       _createProjectUseCase = createProjectUseCase,
       _updateProjectUseCase = updateProjectUseCase,
       _deleteProjectUseCase = deleteProjectUseCase,
       super(const ProjectInitial()) {
    on<ProjectsLoadRequested>(_onProjectsLoadRequested);
    on<ProjectCreateRequested>(_onProjectCreateRequested);
    on<ProjectUpdateRequested>(_onProjectUpdateRequested);
    on<ProjectDeleteRequested>(_onProjectDeleteRequested);
  }

  Future<void> _onProjectsLoadRequested(
    ProjectsLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());
    try {
      // LEARNING: Cancel previous subscription before
      // starting a new one to prevent duplicate listeners
      await _projectsSubscription?.cancel();

      // LEARNING: emit.forEach converts a Stream into
      // BLoC states. Every time Firestore updates the
      // stream, ProjectsLoaded is emitted automatically
      // This is the real time magic of Firestore + BLoC
      await emit.forEach(
        _getProjectsUseCase.execute(workspaceId: event.workspaceId),
        onData: (projects) => ProjectsLoaded(projects),
        onError: (error, _) => ProjectError(error.toString()),
      );
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onProjectCreateRequested(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _createProjectUseCase.execute(
        name: event.name,
        description: event.description,
        workspaceId: event.workspaceId,
        createdBy: event.createdBy,
        priority: event.priority,
        dueDate: event.dueDate,
      );
      // ← Remove emit(ProjectOperationSuccess) here
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onProjectUpdateRequested(
    ProjectUpdateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _updateProjectUseCase.execute(
        projectId: event.projectId,
        workspaceId: event.workspaceId,
        name: event.name,
        description: event.description,
        status: event.status,
        priority: event.priority,
        dueDate: event.dueDate,
      );
      // LEARNING: Don't emit ProjectOperationSuccess here
      // because emit.forEach is still running the stream
      // emitting a different state interrupts it
      // The stream will automatically emit ProjectsLoaded
      // with the updated data via Firestore real-time update
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onProjectDeleteRequested(
    ProjectDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _deleteProjectUseCase.execute(
        projectId: event.projectId,
        workspaceId: event.workspaceId,
        deletedBy: event.deletedBy,
      );
      // No emit needed — Firestore stream handles the update
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}
