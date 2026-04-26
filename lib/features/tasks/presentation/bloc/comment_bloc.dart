import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/tasks/domain/usecases/add_comment_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/delete_comment_usecase.dart';
import 'package:task_manager/features/tasks/domain/usecases/get_comments_usecase.dart';
import 'package:task_manager/features/tasks/presentation/bloc/comment_event.dart';
import 'package:task_manager/features/tasks/presentation/bloc/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  CommentBloc({
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(CommentInitial()) {
    on<CommentsLoadRequested>(_onCommentsLoadRequested);
    on<CommentAddRequested>(_onCommentAddRequested);
    on<CommentDeleteRequested>(_onCommentDeleteRequested);
  }

  Future<void> _onCommentsLoadRequested(
    CommentsLoadRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    await emit.forEach(
      getCommentsUseCase(
        workspaceId: event.workspaceId,
        taskId: event.taskId,
      ),
      onData: (comments) => CommentsLoaded(comments),
      onError: (_, __) => const CommentError('Failed to load comments'),
    );
  }

  Future<void> _onCommentAddRequested(
    CommentAddRequested event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await addCommentUseCase(
        workspaceId: event.workspaceId,
        taskId: event.taskId,
        text: event.text,
        createdBy: event.createdBy,
        createdByName: event.createdByName,
      );
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onCommentDeleteRequested(
    CommentDeleteRequested event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await deleteCommentUseCase(
        workspaceId: event.workspaceId,
        taskId: event.taskId,
        commentId: event.commentId,
      );
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }
}