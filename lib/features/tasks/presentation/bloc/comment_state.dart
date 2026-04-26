import 'package:equatable/equatable.dart';
import 'package:task_manager/features/tasks/domain/entities/comment_entity.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentsLoaded extends CommentState {
  final List<CommentEntity> comments;

  const CommentsLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentAdded extends CommentState {}

class CommentDeleted extends CommentState {}

class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}