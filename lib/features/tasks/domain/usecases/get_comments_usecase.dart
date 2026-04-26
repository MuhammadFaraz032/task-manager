import 'package:task_manager/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_manager/features/tasks/domain/entities/comment_entity.dart';

class GetCommentsUseCase {
  final TaskRepository repository;

  GetCommentsUseCase(this.repository);

  Stream<List<CommentEntity>> call({
    required String workspaceId,
    required String taskId,
  }) {
    return repository.getComments(
      workspaceId: workspaceId,
      taskId: taskId,
    );
  }
}