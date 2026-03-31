import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firestore_service.dart';

// ─── Events ──────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationEvent {
  const NotificationsLoadRequested();
}

class NotificationMarkRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationsUpdated extends NotificationEvent {
  final List<Map<String, dynamic>> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

// ─── States ──────────────────────────────────────────

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationsLoaded extends NotificationState {
  final List<Map<String, dynamic>> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────

/// Notification BLoC — Real-time notifications with unread count
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  StreamSubscription? _notificationsSub;

  NotificationBloc({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const NotificationInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationMarkRead>(_onMarkRead);
    on<NotificationsUpdated>(_onUpdated);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final uid = _authService.uid;
    if (uid == null) {
      emit(const NotificationError('يجب تسجيل الدخول'));
      return;
    }

    await _notificationsSub?.cancel();
    _notificationsSub = _firestoreService
        .streamNotifications(uid)
        .listen((notifications) {
      if (!isClosed) {
        add(NotificationsUpdated(notifications));
      }
    });
  }

  Future<void> _onUpdated(
    NotificationsUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    final unread = event.notifications
        .where((n) => n['read'] != true)
        .length;

    emit(NotificationsLoaded(
      notifications: event.notifications,
      unreadCount: unread,
    ));
  }

  Future<void> _onMarkRead(
    NotificationMarkRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _firestoreService.markNotificationRead(event.notificationId);
    } catch (e) {
      // Silently fail — notification will remain unread
    }
  }

  @override
  Future<void> close() {
    _notificationsSub?.cancel();
    return super.close();
  }
}
