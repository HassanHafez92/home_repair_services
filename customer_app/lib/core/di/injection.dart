import 'package:get_it/get_it.dart';

import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cloud_functions_service.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/jobs/bloc/job_bloc.dart';
import '../../features/notifications/bloc/notification_bloc.dart';
import '../../features/wallet/bloc/wallet_bloc.dart';

final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // ─── Services (Singletons) ──────────────────────────
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(),
  );

  sl.registerLazySingleton<FirestoreService>(
    () => FirestoreService(),
  );

  sl.registerLazySingleton<CloudFunctionsService>(
    () => CloudFunctionsService(),
  );

  // ─── BLoCs (Factory — new instance each time) ───────
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authService: sl<FirebaseAuthService>()),
  );


  sl.registerFactory<JobBloc>(
    () => JobBloc(
      authService: sl<FirebaseAuthService>(),
      firestoreService: sl<FirestoreService>(),
      functionsService: sl<CloudFunctionsService>(),
    ),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      authService: sl<FirebaseAuthService>(),
      firestoreService: sl<FirestoreService>(),
    ),
  );

  sl.registerFactory<WalletBloc>(
    () => WalletBloc(
      authService: sl<FirebaseAuthService>(),
      firestoreService: sl<FirestoreService>(),
    ),
  );
}
