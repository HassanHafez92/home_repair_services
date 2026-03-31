import 'package:get_it/get_it.dart';

import '../services/tech_auth_service.dart';
import '../services/tech_firestore_service.dart';
import '../services/tech_functions_service.dart';
import '../../features/auth/bloc/tech_auth_bloc.dart';
import '../../features/jobs/bloc/tech_job_bloc.dart';
import '../../features/wallet/bloc/tech_wallet_bloc.dart';

final GetIt sl = GetIt.instance;

/// Initialize all technician app dependencies
Future<void> initTechDependencies() async {
  // ─── Services (Singletons) ──────────────────────────
  sl.registerLazySingleton<TechAuthService>(
    () => TechAuthService(),
  );

  sl.registerLazySingleton<TechFirestoreService>(
    () => TechFirestoreService(),
  );

  sl.registerLazySingleton<TechFunctionsService>(
    () => TechFunctionsService(),
  );

  // ─── BLoCs (Factory) ───────────────────────────────
  sl.registerFactory<TechAuthBloc>(
    () => TechAuthBloc(authService: sl<TechAuthService>()),
  );

  sl.registerFactory<TechJobBloc>(
    () => TechJobBloc(
      authService: sl<TechAuthService>(),
      firestoreService: sl<TechFirestoreService>(),
      functionsService: sl<TechFunctionsService>(),
    ),
  );

  sl.registerFactory<TechWalletBloc>(
    () => TechWalletBloc(
      authService: sl<TechAuthService>(),
      firestoreService: sl<TechFirestoreService>(),
      functionsService: sl<TechFunctionsService>(),
    ),
  );
}
