import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchMyData();
  }

  Future<void> _fetchMyData() async {
    final supabase = ref.read(supabaseClientProvider);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Automatically fetches the logged-in user's data
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching portfolio: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) return;
    String finalUrl = urlString.trim();
    if (!finalUrl.startsWith('http')) finalUrl = 'https://$finalUrl';
    final Uri url = Uri.parse(finalUrl);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Link Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (_profileData == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("Profile not found", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MY PORTFOLIO", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.amber,
                backgroundImage: (_profileData!['avatar_url'] != null && _profileData!['avatar_url'].toString().isNotEmpty)
                    ? NetworkImage(_profileData!['avatar_url'])
                    : null,
                child: (_profileData!['avatar_url'] == null || _profileData!['avatar_url'].toString().isEmpty)
                    ? const Icon(Icons.person, size: 60, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(height: 25),

            Text(
              (_profileData!['stage_name'] ?? 'No Name').toString().toLowerCase(),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            Row(
              children: [
                Text((_profileData!['role_type'] ?? 'PROFESSIONAL').toString().toUpperCase(),
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                const Text(" • ", style: TextStyle(color: Colors.white54)),
                Text(_profileData!['location_area'] ?? 'Chennai', style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 15),

            // Experience Level Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text("Level: ${_profileData!['experience_level'] ?? 'Fresher'}",
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),

            const SizedBox(height: 40),
            const Text("WORK & LINKS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 20),

            _buildSocialButton(
              icon: Icons.camera_alt_outlined,
              label: "Instagram Portfolio",
              onTap: () => _launchURL(_profileData!['instagram_url']),
            ),

            const SizedBox(height: 15),

            _buildSocialButton(
              icon: Icons.play_circle_outline,
              label: "YouTube Showreel",
              onTap: () => _launchURL(_profileData!['youtube_url']),
            ),

            const SizedBox(height: 30),

            Center(
              child: TextButton.icon(
                onPressed: () async {
                  final supabase = ref.read(supabaseClientProvider);
                  await supabase.auth.signOut();
                  if (!mounted) return;
                  context.go('/splash');
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                label: const Text("Logout from CiniFind", style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}