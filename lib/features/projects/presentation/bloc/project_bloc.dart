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
  })  : _getProjectsUseCase = getProjectsUseCase,
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
      // LEARNING: No need to emit ProjectsLoaded here
      // Firestore stream automatically emits the updated
      // list via emit.forEach above
      emit(const ProjectOperationSuccess('Project created'));
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
        name: event.name,
        description: event.description,
        status: event.status,
        priority: event.priority,
        dueDate: event.dueDate,
      );
      emit(const ProjectOperationSuccess('Project updated'));
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
        deletedBy: event.deletedBy,
      );
      emit(const ProjectOperationSuccess('Project deleted'));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    return super.close();
  }
}