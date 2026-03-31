import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'core/theme/tech_theme.dart';
import 'core/router/tech_router.dart';
import 'core/di/tech_injection.dart';
import 'features/auth/bloc/tech_auth_bloc.dart';
import 'features/jobs/bloc/tech_job_bloc.dart';
import 'features/wallet/bloc/tech_wallet_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependencies
  await initTechDependencies();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FixawyTechApp());
}

/// Root Technician App Widget — BLoC providers
class FixawyTechApp extends StatefulWidget {
  const FixawyTechApp({super.key});

  @override
  State<FixawyTechApp> createState() => _FixawyTechAppState();
}

class _FixawyTechAppState extends State<FixawyTechApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = TechRouter.router(sl<TechAuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TechAuthBloc>(
          create: (_) => sl<TechAuthBloc>()..add(const TechAuthCheckRequested()),
        ),
        BlocProvider<TechJobBloc>(
          create: (_) => sl<TechJobBloc>(),
        ),
        BlocProvider<TechWalletBloc>(
          create: (_) => sl<TechWalletBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'فيكساوي فني — Fixawy Tech',
        debugShowCheckedModeBanner: false,

        locale: const Locale('ar', 'EG'),
        supportedLocales: const [
          Locale('ar', 'EG'),
          Locale('en', 'US'),
        ],

        theme: TechTheme.lightTheme,
        darkTheme: TechTheme.darkTheme,
        themeMode: ThemeMode.light,

        routerConfig: _router,

        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
