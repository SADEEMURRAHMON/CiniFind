import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Actor';
  bool _isLoading = false;

  static const _roles = ['Actor', 'Director', 'Crew'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final userId = authResponse.user?.id;
      if (userId == null) {
        throw const AuthException('Sign-up completed but user id was not returned.');
      }

      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'full_name': _fullNameController.text.trim(),
        'role': _selectedRole,
      });

      if (!mounted) return;
      context.go('/home');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5C518);
    const bg = Color(0xFF0D0D0D);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: bg,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: gold),
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Full name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: gold),
                    ),
                  ),
                  validator: (value) {
                    final email = (value ?? '').trim();
                    if (email.isEmpty) return 'Email is required';
                    if (!email.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: gold),
                    ),
                  ),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.isEmpty) return 'Password is required';
                    if (password.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: gold),
                    ),
                  ),
                  items: _roles
                      .map((role) => DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedRole = value);
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

