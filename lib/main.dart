import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auditions_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'supabase_client_provider.dart';

// Replace these later with your actual Supabase credentials.
const String SUPABASE_URL = 'SUPABASE_URL';
const String SUPABASE_ANON_KEY = 'SUPABASE_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseClient = SupabaseClient(SUPABASE_URL, SUPABASE_ANON_KEY);

  final router = _createRouter();

  runApp(
    ProviderScope(
      overrides: [
        supabaseClientProvider.overrideWithValue(supabaseClient),
      ],
      child: CiniFindApp(router: router),
    ),
  );
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ProfileScreen(userId: id ?? '');
        },
      ),
      GoRoute(
        path: '/auditions',
        builder: (context, state) => const AuditionsScreen(),
      ),
    ],
  );
}

class CiniFindApp extends StatelessWidget {
  const CiniFindApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0D0D0D);
    const gold = Color(0xFFF5C518);

    final theme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
      ),
      useMaterial3: true,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CiniFind',
      theme: theme,
      routerConfig: router,
    );
  }
}
