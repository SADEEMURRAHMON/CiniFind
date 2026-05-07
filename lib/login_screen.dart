import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client_provider.dart';

// Change this line
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// And this line
class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ... keep the rest of your code the same ...
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final supabase = ref.read(supabaseClientProvider);

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_tabController.index == 1) {
        // SIGN UP
        await supabase.auth.signUp(email: email, password: password);
        if (mounted) {
          context.go('/register');
        }
      } else {
        // SIGN IN
        await supabase.auth.signInWithPassword(email: email, password: password);
        if (mounted) context.go('/splash');
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text("CiniFind", style: TextStyle(color: Colors.amber, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const Text("Connect. Create. Conquer.", style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 50),
              Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(25)),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.amber),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  tabs: const [Tab(text: "Login"), Tab(text: "Sign Up")],
                ),
              ),
              const SizedBox(height: 40),
              _buildInput("Email Address", _emailController, false),
              const SizedBox(height: 20),
              _buildInput("Password", _passwordController, true),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleAuth,
                child: Text(_tabController.index == 0 ? "SIGN IN" : "CREATE ACCOUNT",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber)),
      ),
    );
  }
}