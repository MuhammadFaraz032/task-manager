import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/toggle_task_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final ToggleTaskUseCase _toggleTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  StreamSubscription? _tasksSubscription;

  // LEARNING: Store last query params so we can
  // restart the stream after any operation
  String? _lastWorkspaceId;
  String? _lastProjectId;

  TaskBloc({
    required GetTasksUseCase getTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required ToggleTaskUseCase toggleTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  }) : _getTasksUseCase = getTasksUseCase,
       _createTaskUseCase = createTaskUseCase,
       _updateTaskUseCase = updateTaskUseCase,
       _toggleTaskUseCase = toggleTaskUseCase,
       _deleteTaskUseCase = deleteTaskUseCase,
       super(const TaskInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskToggleRequested>(_onTaskToggleRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
  }

  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    // print('🔵 TASKS LOAD REQUESTED: workspaceId=${event.workspaceId}');
    emit(const TaskLoading());
    try {
      await _tasksSubscription?.cancel();
      // print('🔵 Old subscription cancelled');

      _lastWorkspaceId = event.workspaceId;
      _lastProjectId = event.projectId;

      await emit.forEach(
        _getTasksUseCase.execute(
          workspaceId: event.workspaceId,
          projectId: event.projectId,
        ),
        onData: (tasks) {
          // print('🔵 TASKS RECEIVED FROM STREAM: ${tasks.length} tasks');
          return TasksLoaded(tasks);
        },
        onError: (error, _) {
          // print('🔴 STREAM ERROR: $error');
          return TaskError(error.toString());
        },
      );
    } catch (e) {
      // print('🔴 CATCH ERROR: $e');
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onTaskCreateRequested(
    TaskCreateRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _createTaskUseCase.execute(
        title: event.title,
        description: event.description,
        workspaceId: event.workspaceId,
        createdBy: event.createdBy,
        projectId: event.projectId,
        priority: event.priority,
        dueDate: event.dueDate,
        checklist: event.checklist,
        assignedTo: event.assignedTo,
      );
      emit(const TaskOperationSuccess('Task created'));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onTaskUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _updateTaskUseCase.execute(
        taskId: event.taskId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        status: event.status,
        dueDate: event.dueDate,
        checklist: event.checklist,
        assignedTo: event.assignedTo,
      );

      if (_lastWorkspaceId != null) {
        await emit.forEach(
          _getTasksUseCase.execute(
            workspaceId: _lastWorkspaceId!,
            projectId: _lastProjectId,
          ),
          onData: (tasks) => TasksLoaded(tasks),
          onError: (error, _) => TaskError(error.toString()),
        );
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onTaskToggleRequested(
    TaskToggleRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _toggleTaskUseCase.execute(
        taskId: event.taskId,
        completedBy: event.completedBy,
      );

      if (_lastWorkspaceId != null) {
        await emit.forEach(
          _getTasksUseCase.execute(
            workspaceId: _lastWorkspaceId!,
            projectId: _lastProjectId,
          ),
          onData: (tasks) => TasksLoaded(tasks),
          onError: (error, _) => TaskError(error.toString()),
        );
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _deleteTaskUseCase.execute(
        taskId: event.taskId,
        deletedBy: event.deletedBy,
      );

      // LEARNING: Restart the stream after delete
      // so the UI reflects the change immediately
      if (_lastWorkspaceId != null) {
        await emit.forEach(
          _getTasksUseCase.execute(
            workspaceId: _lastWorkspaceId!,
            projectId: _lastProjectId,
          ),
          onData: (tasks) => TasksLoaded(tasks),
          onError: (error, _) => TaskError(error.toString()),
        );
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
