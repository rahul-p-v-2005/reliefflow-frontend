part of 'notification_cubit.dart';

/// Base state for notifications
sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class NotificationInitial extends NotificationState {}

/// Loading state while fetching notifications
class NotificationLoading extends NotificationState {}

/// Loaded state with notifications list and unread count
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// Error state when fetching fails
class NotificationError extends NotificationState {
  final String message;
  final int statusCode;

  const NotificationError({
    required this.message,
    this.statusCode = 500,
  });

  @override
  List<Object?> get props => [message, statusCode];
}
