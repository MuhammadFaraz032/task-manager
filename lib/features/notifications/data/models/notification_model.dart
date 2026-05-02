import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.taskId,
    required super.taskTitle,
    required super.message,
    required super.triggeredBy,
    required super.isRead,
    required super.createdAt,
    super.workspaceId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: data['type'] ?? '',
      taskId: data['taskId'] ?? '',
      taskTitle: data['taskTitle'] ?? '',
      message: data['message'] ?? '',
      triggeredBy: data['triggeredBy'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      workspaceId: data['workspaceId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'message': message,
      'triggeredBy': triggeredBy,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}