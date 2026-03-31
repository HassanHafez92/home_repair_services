import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';

// Auth screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';

// Main screens
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

// Feature screens
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/tracking/presentation/screens/tracking_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/rating_screen.dart';

/// Fixawy App Router — GoRouter configuration
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;
      
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';
      final isOtp = state.matchedLocation == '/otp';
      final isOnboarding = state.matchedLocation == '/onboarding';
      
      final isAuthScreen = isLogin || isOtp || isOnboarding;
      
      if (authState is AuthInitial || authState is AuthLoading) {
        return isSplash ? null : '/splash';
      }
      
      if (authState is AuthUnauthenticated) {
        return isAuthScreen ? null : '/login';
      }
      
      if (authState is AuthNeedsOnboarding) {
        return isOnboarding ? null : '/onboarding';
      }
      
      if (authState is AuthOtpSent) {
        return isOtp ? null : '/otp';
      }
      
      if (authState is AuthAuthenticated) {
        if (isSplash || isAuthScreen) {
          return '/home';
        }
        return null; // Let them go to the requested screen
      }
      
      return null;
    },
    routes: [
      // ─── Splash ──────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ─── Onboarding ─────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ─── Auth ────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '+20';
          return OtpScreen(phoneNumber: phone);
        },
      ),

      // ─── Main Shell (Bottom Nav) ─────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationsScreen(),
            ),
          ),
        ],
      ),

      // ─── Full-screen Routes ──────────────────────────────
      GoRoute(
        path: '/booking',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final category = state.extra as String? ?? 'plumbing';
          return BookingScreen(serviceCategory: category);
        },
      ),
      GoRoute(
        path: '/tracking/:jobId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return TrackingScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/checkout/:jobId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return CheckoutScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/rating/:jobId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return RatingScreen(jobId: jobId);
        },
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFFE85D4A),
            ),
            const SizedBox(height: 16),
            const Text(
              'الصفحة غير موجودة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.message ?? 'حدث خطأ غير متوقع',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Color(0xFF6C757D),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Helper class to convert a Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
