import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/firebase_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC — Manages authentication lifecycle
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService;
  String? _pendingPhoneNumber;
  StreamSubscription? _authSubscription;

  AuthBloc({required FirebaseAuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthOtpRequested>(_onOtpRequested);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthOnboardingCompleted>(_onOnboardingCompleted);

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user != null && state is! AuthOtpSent && state is! AuthLoading) {
        add(const AuthCheckRequested());
      }
    });
  }

  /// Check current auth state on app launch
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = _authService.currentUser;

      if (user == null) {
        // Check if onboarding completed (via shared prefs)
        emit(const AuthUnauthenticated());
        return;
      }

      // Check if user has completed profile setup
      final profile = await _authService.getUserProfile();
      final onboardingDone = profile?['onboardingCompleted'] == true;

      if (!onboardingDone) {
        emit(const AuthNeedsOnboarding());
        return;
      }

      emit(AuthAuthenticated(
        uid: user.uid,
        displayName: profile?['displayName'] ?? user.displayName,
        phone: user.phoneNumber,
        photoUrl: user.photoURL,
      ));
    } catch (e) {
      emit(AuthError('حدث خطأ: ${e.toString()}'));
    }
  }

  /// Send OTP to phone number
  Future<void> _onOtpRequested(
    AuthOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _pendingPhoneNumber = event.phoneNumber;

    final completer = Completer<void>();

    try {
      await _authService.sendOtp(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId) {
          emit(AuthOtpSent(
            verificationId: verificationId,
            phoneNumber: event.phoneNumber,
          ));
          if (!completer.isCompleted) completer.complete();
        },
        onError: (error) {
          emit(AuthError(error));
          if (!completer.isCompleted) completer.complete();
        },
        onAutoVerify: (credential) {
          // Auto-verified on Android — will trigger authStateChanges
        },
      );

      await completer.future;
    } catch (e) {
      emit(AuthError('فشل إرسال كود التحقق: ${e.toString()}'));
    }
  }

  /// Verify the OTP code
  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final userCredential = await _authService.verifyOtp(event.code);
      final user = userCredential.user;

      if (user == null) {
        emit(const AuthError('فشل التحقق'));
        return;
      }

      // Create/update profile
      await _authService.updateUserProfile({
        'phone': user.phoneNumber ?? _pendingPhoneNumber,
        'role': 'customer',
        'lastLogin': DateTime.now().toIso8601String(),
      });

      final profile = await _authService.getUserProfile();
      final onboardingDone = profile?['onboardingCompleted'] == true;

      if (!onboardingDone) {
        emit(const AuthNeedsOnboarding());
      } else {
        emit(AuthAuthenticated(
          uid: user.uid,
          displayName: profile?['displayName'],
          phone: user.phoneNumber,
          photoUrl: user.photoURL,
        ));
      }
    } catch (e) {
      emit(AuthError('كود التحقق غير صحيح: ${e.toString()}'));
    }
  }

  /// Google Sign-In
  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential.user;

      if (user == null) {
        emit(const AuthError('فشل تسجيل الدخول بجوجل'));
        return;
      }

      // Create/update profile
      await _authService.updateUserProfile({
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'role': 'customer',
        'lastLogin': DateTime.now().toIso8601String(),
      });

      final profile = await _authService.getUserProfile();
      final onboardingDone = profile?['onboardingCompleted'] == true;

      if (!onboardingDone) {
        emit(const AuthNeedsOnboarding());
      } else {
        emit(AuthAuthenticated(
          uid: user.uid,
          displayName: user.displayName,
          phone: user.phoneNumber,
          photoUrl: user.photoURL,
        ));
      }
    } catch (e) {
      emit(AuthError('فشل تسجيل الدخول: ${e.toString()}'));
    }
  }

  /// Sign out
  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
    emit(const AuthUnauthenticated());
  }

  /// Mark onboarding complete
  Future<void> _onOnboardingCompleted(
    AuthOnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.updateUserProfile({
        'onboardingCompleted': true,
      });

      final user = _authService.currentUser;
      if (user != null) {
        final profile = await _authService.getUserProfile();
        emit(AuthAuthenticated(
          uid: user.uid,
          displayName: profile?['displayName'] ?? user.displayName,
          phone: user.phoneNumber,
          photoUrl: user.photoURL,
        ));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
