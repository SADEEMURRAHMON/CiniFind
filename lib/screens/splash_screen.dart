import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateByAuthState();
  }

  Future<void> _navigateByAuthState() async {
    final session = Supabase.instance.client.auth.currentSession;
    final targetRoute = session != null ? '/home' : '/login';

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    context.go(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5C518);

    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(
        child: Text(
          'CiniFind',
          style: TextStyle(
            color: gold,
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

