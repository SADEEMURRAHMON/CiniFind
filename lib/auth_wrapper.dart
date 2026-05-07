import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'marketplace_screen.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // This stream listens for login AND logout events automatically
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session != null) {
          // If logged in, show the Hub
          return const MainNavigation();
        } else {
          // If logged out, show the Login screen
          return const LoginScreen();
        }
      },
    );
  }
}