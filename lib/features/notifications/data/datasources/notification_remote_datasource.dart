import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String userId, String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  NotificationRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .doc(notificationId)
        .update({'isRead': true});
  }
}