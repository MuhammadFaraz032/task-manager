import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class CommentsLoadRequested extends CommentEvent {
  final String workspaceId;
  final String taskId;

  const CommentsLoadRequested({
    required this.workspaceId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [workspaceId, taskId];
}

class CommentAddRequested extends CommentEvent {
  final String workspaceId;
  final String taskId;
  final String text;
  final String createdBy;
  final String createdByName;

  const CommentAddRequested({
    required this.workspaceId,
    required this.taskId,
    required this.text,
    required this.createdBy,
    required this.createdByName,
  });

  @override
  List<Object?> get props => [workspaceId, taskId, text, createdBy];
}

class CommentDeleteRequested extends CommentEvent {
  final String workspaceId;
  final String taskId;
  final String commentId;

  const CommentDeleteRequested({
    required this.workspaceId,
    required this.taskId,
    required this.commentId,
  });

  @override
  List<Object?> get props => [workspaceId, taskId, commentId];
}