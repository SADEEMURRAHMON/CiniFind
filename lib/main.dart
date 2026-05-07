import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'discover_screen.dart';
import 'join_form_screen.dart';
import 'login_screen.dart';
import 'main_navigation.dart';
import 'profile_view_screen.dart';
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
          return ProfileScreen(id: id ?? '');
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

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  StreamSubscription<AuthState>? _authSub;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _bootstrapAuth();
  }

  Future<void> _bootstrapAuth() async {
    final supabase = ref.read(supabaseClientProvider);

    // Keep listening for auth changes while splash is visible.
    _authSub = supabase.auth.onAuthStateChange.listen((event) {
      if (!mounted) return;
      _redirectBySession(event.session);
    });

    // Navigate based on the current session first (if already available).
    final session = supabase.auth.currentSession;
    if (!mounted) return;
    if (session != null) {
      _redirectBySession(session);
    }
  }

  void _redirectBySession(Session? session) {
    if (_didNavigate) return;
    _didNavigate = true;

    final isAuthed = session != null;
    context.go(isAuthed ? '/home' : '/login');
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5C518);

    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(
        child: CircularProgressIndicator(color: gold),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const JoinFormScreen();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}

class AuditionsScreen extends StatelessWidget {
  const AuditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DiscoverScreen();
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({required this.id, super.key});

  final String id;

  Future<Map<String, dynamic>?> _fetchProfile(SupabaseClient supabase) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .single();

      if (data is Map<String, dynamic>) return data;
      return Map<String, dynamic>.from(data as Map);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseClientProvider);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchProfile(supabase),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profileData = snapshot.data;
        if (profileData == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(
              child: Text(
                'Profile not found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return ProfileViewScreen(profileData: profileData);
      },
    );
  }
}