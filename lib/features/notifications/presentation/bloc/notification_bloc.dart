import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkReadUseCase markReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markReadUseCase,
  }) : super(NotificationInitial()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationMarkReadRequested>(_onMarkReadRequested);
  }

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    await emit.forEach(
      getNotificationsUseCase(event.userId),
      onData: (notifications) => NotificationsLoaded(notifications),
      onError: (_, __) => NotificationError('Failed to load notifications'),
    );
  }

  Future<void> _onMarkReadRequested(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await markReadUseCase(event.userId, event.notificationId);
  }
}