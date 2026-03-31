import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/tech_auth_service.dart';

// ─── Events ──────────────────────────────────────────

abstract class TechAuthEvent extends Equatable {
  const TechAuthEvent();
  @override
  List<Object?> get props => [];
}

class TechAuthCheckRequested extends TechAuthEvent {
  const TechAuthCheckRequested();
}

class TechAuthOtpRequested extends TechAuthEvent {
  final String phoneNumber;
  const TechAuthOtpRequested(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class TechAuthOtpSubmitted extends TechAuthEvent {
  final String code;
  const TechAuthOtpSubmitted(this.code);
  @override
  List<Object?> get props => [code];
}

class TechAuthKycSubmitted extends TechAuthEvent {
  final String category;
  // Additional document paths or URLs would go here in a real app
  const TechAuthKycSubmitted(this.category);
  @override
  List<Object?> get props => [category];
}

class TechAuthSignOutRequested extends TechAuthEvent {
  const TechAuthSignOutRequested();
}

class TechAuthStatusToggled extends TechAuthEvent {
  final bool isOnline;
  const TechAuthStatusToggled(this.isOnline);
  @override
  List<Object?> get props => [isOnline];
}

// ─── States ──────────────────────────────────────────

abstract class TechAuthState extends Equatable {
  const TechAuthState();
  @override
  List<Object?> get props => [];
}

class TechAuthInitial extends TechAuthState {
  const TechAuthInitial();
}

class TechAuthLoading extends TechAuthState {
  const TechAuthLoading();
}

class TechAuthUnauthenticated extends TechAuthState {
  const TechAuthUnauthenticated();
}

class TechAuthOtpSent extends TechAuthState {
  final String verificationId;
  final String phoneNumber;
  const TechAuthOtpSent({required this.verificationId, required this.phoneNumber});
  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

/// KYC not yet submitted
class TechAuthNeedsKyc extends TechAuthState {
  const TechAuthNeedsKyc();
}

/// KYC submitted, awaiting admin approval
class TechAuthKycPending extends TechAuthState {
  const TechAuthKycPending();
}

/// Fully authenticated and approved
class TechAuthAuthenticated extends TechAuthState {
  final String uid;
  final String? displayName;
  final String? phone;
  final List<String> categories;
  final bool isOnline;

  const TechAuthAuthenticated({
    required this.uid,
    this.displayName,
    this.phone,
    this.categories = const [],
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [uid, displayName, phone, categories, isOnline];
}

class TechAuthError extends TechAuthState {
  final String message;
  const TechAuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────

/// Technician Auth BLoC — Handles auth + KYC gating
class TechAuthBloc extends Bloc<TechAuthEvent, TechAuthState> {
  final TechAuthService _authService;
  StreamSubscription? _authSub;

  TechAuthBloc({required TechAuthService authService})
      : _authService = authService,
        super(const TechAuthInitial()) {
    on<TechAuthCheckRequested>(_onCheck);
    on<TechAuthOtpRequested>(_onOtpRequested);
    on<TechAuthOtpSubmitted>(_onOtpSubmitted);
    on<TechAuthKycSubmitted>(_onKycSubmitted);
    on<TechAuthSignOutRequested>(_onSignOut);
    on<TechAuthStatusToggled>(_onStatusToggled);

    _authSub = _authService.authStateChanges.listen((user) {
      if (user != null && state is! TechAuthOtpSent && state is! TechAuthLoading) {
        add(const TechAuthCheckRequested());
      }
    });
  }

  Future<void> _onCheck(
    TechAuthCheckRequested event,
    Emitter<TechAuthState> emit,
  ) async {
    emit(const TechAuthLoading());

    try {
      final user = _authService.currentUser;
      if (user == null) {
        emit(const TechAuthUnauthenticated());
        return;
      }

      final kycStatus = await _authService.getKycStatus();

      switch (kycStatus) {
        case 'approved':
          final profile = await _authService.getTechnicianProfile();
          final cats = (profile?['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [];
          final bool isOnline = profile?['isOnline'] == true;
          emit(TechAuthAuthenticated(
            uid: user.uid,
            displayName: profile?['displayName'] ?? user.displayName,
            phone: user.phoneNumber,
            categories: cats,
            isOnline: isOnline,
          ));
          break;
        case 'pending':
          emit(const TechAuthKycPending());
          break;
        default:
          emit(const TechAuthNeedsKyc());
      }
    } catch (e) {
      emit(TechAuthError('حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> _onOtpRequested(
    TechAuthOtpRequested event,
    Emitter<TechAuthState> emit,
  ) async {
    emit(const TechAuthLoading());
    final completer = Completer<void>();

    try {
      await _authService.sendOtp(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId) {
          emit(TechAuthOtpSent(
            verificationId: verificationId,
            phoneNumber: event.phoneNumber,
          ));
          if (!completer.isCompleted) completer.complete();
        },
        onError: (error) {
          emit(TechAuthError(error));
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future;
    } catch (e) {
      emit(TechAuthError('فشل إرسال كود التحقق: ${e.toString()}'));
    }
  }

  Future<void> _onOtpSubmitted(
    TechAuthOtpSubmitted event,
    Emitter<TechAuthState> emit,
  ) async {
    emit(const TechAuthLoading());

    try {
      final userCredential = await _authService.verifyOtp(event.code);
      final user = userCredential.user;
      if (user == null) {
        emit(const TechAuthError('فشل التحقق'));
        return;
      }

      await _authService.updateTechnicianProfile({
        'phone': user.phoneNumber,
        'role': 'technician',
        'lastLogin': DateTime.now().toIso8601String(),
      });

      // Check KYC status
      add(const TechAuthCheckRequested());
    } catch (e) {
      emit(TechAuthError('كود التحقق غير صحيح: ${e.toString()}'));
    }
  }

  Future<void> _onKycSubmitted(
    TechAuthKycSubmitted event,
    Emitter<TechAuthState> emit,
  ) async {
    emit(const TechAuthLoading());
    try {
      await _authService.updateTechnicianProfile({
        'kycStatus': 'pending',
        'categories': [event.category],
        'submittedAt': DateTime.now().toIso8601String(),
      });
      emit(const TechAuthKycPending());
    } catch (e) {
      emit(TechAuthError('فشل تقديم طلب التوثيق: ${e.toString()}'));
    }
  }

  Future<void> _onSignOut(
    TechAuthSignOutRequested event,
    Emitter<TechAuthState> emit,
  ) async {
    await _authService.signOut();
    emit(const TechAuthUnauthenticated());
  }

  Future<void> _onStatusToggled(
    TechAuthStatusToggled event,
    Emitter<TechAuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TechAuthAuthenticated) return;

    try {
      await _authService.updateTechnicianProfile({
        'isOnline': event.isOnline,
      });

      emit(TechAuthAuthenticated(
        uid: currentState.uid,
        displayName: currentState.displayName,
        phone: currentState.phone,
        categories: currentState.categories,
        isOnline: event.isOnline,
      ));
    } catch (e) {
      // Revert if failed but perhaps show an error state briefly
      emit(TechAuthError('فشل تحديث الحالة: ${e.toString()}'));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
