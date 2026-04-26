import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';

class DeleteCommentUseCase {
  final TaskRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String taskId,
    required String commentId,
  }) {
    return repository.deleteComment(
      workspaceId: workspaceId,
      taskId: taskId,
      commentId: commentId,
    );
  }
}