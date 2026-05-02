import '../repositories/notification_repository.dart';

class MarkReadUseCase {
  final NotificationRepository repository;
  MarkReadUseCase(this.repository);

  Future<void> call(String userId, String notificationId) {
    return repository.markAsRead(userId, notificationId);
  }
}