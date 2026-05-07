import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_view_screen.dart'; // We will create this in the next step

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _currentIndex = 0;
  String _selectedRoleFilter = 'All';

  // Standardized Tags for the "No-Typing" Search Engine
  // The standardized list for CiniFind Search & Signup
  final List<String> _roles = [
    'All',
    'Actor/Actress',
    'Director',
    'Camera Man',
    'Editors',
    'Scriptwriter',
    'Music Director',
    'Location Owner',
    'Accessories',
    'Costume Designer',
    'Dubbing Artist',
    'Lyricist'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CiniFind',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Only show search chips if we are in the Talent Marketplace
          if (_currentIndex == 0) _buildFilterChips(),
          Expanded(child: _buildMainContent()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.moped), label: 'Loc'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Acc'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: _roles.map((role) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(role),
            selected: _selectedRoleFilter == role,
            onSelected: (selected) {
              setState(() => _selectedRoleFilter = role);
            },
            selectedColor: Colors.amber,
            labelStyle: TextStyle(
              color: _selectedRoleFilter == role ? Colors.black : Colors.white,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMainContent() {
    // Determine which table to fetch based on the bottom nav index
    String table;
    if (_currentIndex == 0) table = 'profiles';
    else if (_currentIndex == 1) table = 'shoot_spaces';
    else if (_currentIndex == 2) table = 'accessories';
    else return const Center(child: Text("Feature Coming Soon (Portfolio/Profile)"));

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client.from(table).stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var items = snapshot.data!;

        // Apply Search Filter for Talent Marketplace
        if (_currentIndex == 0 && _selectedRoleFilter != 'All') {
          items = items.where((item) {
            final roles = (item['skills'] ?? '').toString().toLowerCase();
            return roles.contains(_selectedRoleFilter.toLowerCase());
          }).toList();
        }

        if (items.isEmpty) return const Center(child: Text("No listings found in this category"));

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.person, color: Colors.black),
                ),
                title: Text(
                  item['full_name'] ?? item['title'] ?? item['item_name'] ?? 'Untitled',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${item['skills'] ?? item['location_area'] ?? ''} • ⭐ ${item['rating'] ?? 'New'}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.amber),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileViewScreen(profileData: item))
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}