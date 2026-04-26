import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

class AddCommentUseCase {
  final TaskRepository repository;

  AddCommentUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String taskId,
    required String text,
    required String createdBy,
    required String createdByName,
  }) {
    return repository.addComment(
      workspaceId: workspaceId,
      taskId: taskId,
      text: text,
      createdBy: createdBy,
      createdByName: createdByName,
    );
  }
}