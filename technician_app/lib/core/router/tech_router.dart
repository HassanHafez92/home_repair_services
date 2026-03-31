import 'package:go_router/go_router.dart';
import 'go_router_refresh_stream.dart';

// Auth
import '../../features/auth/bloc/tech_auth_bloc.dart';
import '../../features/auth/presentation/screens/tech_login_screen.dart';
import '../../features/auth/presentation/screens/tech_otp_screen.dart';

// Main
import '../../features/dashboard/presentation/screens/tech_dashboard_screen.dart';
import '../../features/jobs/presentation/screens/job_alerts_screen.dart';
import '../../features/jobs/presentation/screens/job_execution_screen.dart';
import '../../features/jobs/presentation/screens/invoice_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/kyc/presentation/screens/kyc_screen.dart';
import '../../features/profile/presentation/screens/tech_profile_screen.dart';

class TechRouter {
  TechRouter._();

  static GoRouter router(TechAuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final returningRoutes = ['/login', '/otp'];
        final isAuthRoute = returningRoutes.contains(state.matchedLocation);

        if (authState is TechAuthUnauthenticated || authState is TechAuthInitial) {
          return isAuthRoute ? null : '/login';
        }

        if (authState is TechAuthNeedsKyc || authState is TechAuthKycPending) {
          return '/kyc';
        }

        if (authState is TechAuthAuthenticated) {
          if (isAuthRoute || state.matchedLocation == '/kyc') {
            return '/dashboard';
          }
        }
        return null;
      },
      debugLogDiagnostics: true,
      routes: [
        // Auth
        GoRoute(
          path: '/login',
          builder: (context, state) => const TechLoginScreen(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) {
            final phone = state.extra as String? ?? '';
            return TechOtpScreen(phoneNumber: phone);
          },
        ),

        // KYC
        GoRoute(
          path: '/kyc',
          builder: (context, state) => const KycScreen(),
        ),

        // Dashboard
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const TechDashboardScreen(),
        ),

        // Job Alerts
        GoRoute(
          path: '/job-alerts',
          builder: (context, state) => const JobAlertsScreen(),
        ),

        // Job Execution
        GoRoute(
          path: '/job/:jobId',
          builder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            return JobExecutionScreen(jobId: jobId);
          },
        ),

        // Invoice Builder
        GoRoute(
          path: '/invoice/:jobId',
          builder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            return InvoiceScreen(jobId: jobId);
          },
        ),

        // Wallet
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletScreen(),
        ),

        // Profile
        GoRoute(
          path: '/profile',
          builder: (context, state) => const TechProfileScreen(),
        ),
      ],
    );
  }
}
