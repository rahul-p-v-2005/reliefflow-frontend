import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reliefflow_frontend_public_app/models/notification_model.dart';
import 'package:reliefflow_frontend_public_app/services/notification_service.dart';

part 'notification_state.dart';

/// Cubit for managing notification state
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  /// Load notifications from the API
  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await NotificationService.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      final errorMessage = e.toString();
      final statusCode = errorMessage.contains('Unauthorized') ? 401 : 500;
      emit(
        NotificationError(
          message: errorMessage,
          statusCode: statusCode,
        ),
      );
    }
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refresh() async {
    await loadNotifications();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      final success = await NotificationService.markAsRead(notificationId);
      if (success) {
        // Update local state
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationModel(
              id: n.id,
              title: n.title,
              body: n.body,
              recipientId: n.recipientId,
              type: n.type,
              targetUserType: n.targetUserType,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
        emit(
          NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
          ),
        );
      }
    }
  }

  /// Get only the unread count (lightweight check)
  Future<void> updateUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      final currentState = state;
      if (currentState is NotificationLoaded) {
        emit(
          NotificationLoaded(
            notifications: currentState.notifications,
            unreadCount: count,
          ),
        );
      }
    } catch (_) {
      // Silently fail - don't disrupt UI for badge count
    }
  }
}
