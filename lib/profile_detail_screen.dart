import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final dynamic profile; // This accepts the Map data from DiscoverScreen

  const ProfileDetailsScreen({super.key, required this.profile});

  // Function to handle Instagram and YouTube links
  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) return;

    String finalUrl = urlString.trim();
    if (!finalUrl.startsWith('http')) {
      finalUrl = 'https://$finalUrl';
    }

    final Uri url = Uri.parse(finalUrl);

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $finalUrl');
      }
    } catch (e) {
      debugPrint("Link Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 1. The Header Image (SliverAppBar)
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: (profile['avatar_url'] != null && profile['avatar_url'].toString().isNotEmpty)
                  ? Image.network(
                profile['avatar_url'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.person, size: 100, color: Colors.white24),
                ),
              )
                  : Container(
                color: Colors.grey[900],
                child: const Icon(Icons.person, size: 100, color: Colors.white24),
              ),
            ),
          ),

          // 2. The Content Section
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stage Name
                    Text(
                      (profile['stage_name'] ?? 'Professional').toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Role Type
                    Text(
                      profile['role_type'] ?? 'Film Professional',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          profile['location_area'] ?? 'Chennai',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 40),

                    // Bio Section
                    const Text(
                      "ABOUT",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile['bio'] ?? "Dedicated film professional looking for creative collaborations in the industry.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6, // Fixed the lineHeight error here
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Social & Work Links
                    const Text(
                      "CONNECT & WORK",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 20),

                    _buildSocialLink(
                      icon: Icons.camera_alt_outlined,
                      title: "Instagram Profile",
                      onTap: () => _launchURL(profile['instagram_url']),
                    ),
                    const SizedBox(height: 12),
                    _buildSocialLink(
                      icon: Icons.play_circle_outline,
                      title: "Work Showreel",
                      onTap: () => _launchURL(profile['youtube_url']),
                    ),

                    const SizedBox(height: 50), // Bottom padding
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Helper widget for links
  Widget _buildSocialLink({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.open_in_new, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}