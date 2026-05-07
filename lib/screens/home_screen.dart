import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _titles = [
    'Feed / Discover',
    'Auditions',
    'Messages',
    'Profile',
  ];

  Widget _buildPlaceholder(String label) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0D0D0D);
    const gold = Color(0xFFF5C518);

    final pages = <Widget>[
      _buildPlaceholder('Feed / Discover'),
      _buildPlaceholder('Auditions'),
      _buildPlaceholder('Messages'),
      _buildPlaceholder('Profile'),
    ];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'CiniFind',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: background,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: background,
        selectedItemColor: gold,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Auditions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

