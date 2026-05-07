import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client_provider.dart';
import 'portfolio_screen.dart';
import 'discover_screen.dart';
import 'profile_detail_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  List<dynamic> _profiles = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  String _selectedFilterRole = 'All';
  final List<String> _filterOptions = [
    'All', 'Actor/Actress', 'Director', 'Camera Man', 'Editors',
    'Scriptwriter', 'Music Director', 'Lyricist'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfiles() async {
    if (_profiles.isEmpty) setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      var query = supabase.from('profiles').select();

      if (_selectedFilterRole != 'All') {
        // Updated filter logic for better reliability
        query = query.eq('role_type', _selectedFilterRole);
      }

      String searchText = _searchController.text.trim();
      if (searchText.isNotEmpty) {
        query = query.or('stage_name.ilike.%$searchText%,location_area.ilike.%$searchText%');
      }

      final data = await query;
      setState(() {
        _profiles = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Search Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("CiniFind", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        actions: [
          // RESTORED: Logout button from original design
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final supabase = ref.read(supabaseClientProvider);
              await supabase.auth.signOut();
              if (!mounted) return;
              context.go('/splash');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: "Search name or area...",
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search, color: Colors.amber, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) => _fetchProfiles(),
              ),
            ),
          ),

          // 2. RESTORED: Horizontal Filter Tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: _filterOptions.map((role) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(role),
                    onPressed: () {
                      setState(() => _selectedFilterRole = role);
                      _fetchProfiles();
                    },
                    backgroundColor: _selectedFilterRole == role ? Colors.amber : Colors.white10,
                    labelStyle: TextStyle(
                        color: _selectedFilterRole == role ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. Profiles List
          Expanded(
            child: _isLoading && _profiles.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : RefreshIndicator(
              color: Colors.amber,
              backgroundColor: Colors.grey[900],
              onRefresh: _fetchProfiles,
              child: _profiles.isEmpty
                  ? const Center(child: Text("No professionals found", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final profile = _profiles[index];
                  return _buildProfileCard(profile);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(dynamic profile) {
    return GestureDetector(
      onTap: () {
        final id = profile['id']?.toString();
        if (id != null && id.isNotEmpty) {
          context.go('/profile/$id');
          return;
        }

        // Fallback to the existing detailed widget if the profile id is missing.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailsScreen(profile: profile),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.amber,
              backgroundImage: (profile['avatar_url'] != null && profile['avatar_url'].toString().isNotEmpty)
                  ? NetworkImage(profile['avatar_url'])
                  : null,
              child: (profile['avatar_url'] == null || profile['avatar_url'].toString().isEmpty)
                  ? const Icon(Icons.person, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile['stage_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(profile['role_type'] ?? 'No Role', style: const TextStyle(color: Colors.amber, fontSize: 13)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(profile['location_area'] ?? 'Remote', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}