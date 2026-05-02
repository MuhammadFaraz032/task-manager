import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String type;
  final String taskId;
  final String taskTitle;
  final String message;
  final String triggeredBy;
  final bool isRead;
  final DateTime createdAt;
  final String? workspaceId;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.taskId,
    required this.taskTitle,
    required this.message,
    required this.triggeredBy,
    required this.isRead,
    required this.createdAt,
    this.workspaceId,
  });

  @override
  List<Object?> get props => [id, type, taskId, taskTitle, message, triggeredBy, isRead, createdAt, workspaceId];
}