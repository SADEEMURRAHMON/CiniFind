import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_wrapper.dart'; // We will create this next

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pvucrfzxlnhyszlarvwq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2dWNyZnp4bG5oeXN6bGFydndxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzMTM2ODcsImV4cCI6MjA5MDg4OTY4N30.hGjVPTH0hzV9vajd0hD5cmw7ZP7hYYzntHVmkNVdxc8',
  );

  runApp(const CiniFindApp());
}

class CiniFindApp extends StatelessWidget {
  const CiniFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CiniFind',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white:wq,
        scaffoldBackgroundColor: Colors.red,
        colorScheme: const ColorScheme.dark(primary: Colors.amber),
      ),
      home: const AuthWrapper(),
    );
  }
}