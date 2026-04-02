import 'package:equatable/equatable.dart';
import 'package:task_manager/features/tasks/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TasksLoaded extends TaskState {
  final List<TaskEntity> tasks;
  const TasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskOperationSuccess extends TaskState {
  final String message;
  const TaskOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}