import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource dataSource;
  NotificationRepositoryImpl({required this.dataSource});

  @override
  Stream<List<NotificationEntity>> getNotifications(String userId) {
    return dataSource.getNotifications(userId);
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) {
    return dataSource.markAsRead(userId, notificationId);
  }
}