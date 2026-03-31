import 'package:equatable/equatable.dart';

/// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check initial auth state
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Send OTP to phone
class AuthOtpRequested extends AuthEvent {
  final String phoneNumber;

  const AuthOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// Verify OTP code
class AuthOtpSubmitted extends AuthEvent {
  final String code;

  const AuthOtpSubmitted(this.code);

  @override
  List<Object?> get props => [code];
}

/// Google sign-in
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Mark onboarding complete
class AuthOnboardingCompleted extends AuthEvent {
  const AuthOnboardingCompleted();
}
