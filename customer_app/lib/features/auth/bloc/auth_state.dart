import 'package:equatable/equatable.dart';

/// Auth States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial unknown state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// First-time user needs onboarding
class AuthNeedsOnboarding extends AuthState {
  const AuthNeedsOnboarding();
}

/// OTP was sent to phone
class AuthOtpSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthOtpSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final String uid;
  final String? displayName;
  final String? phone;
  final String? photoUrl;

  const AuthAuthenticated({
    required this.uid,
    this.displayName,
    this.phone,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, displayName, phone, photoUrl];
}

/// Error occurred
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
