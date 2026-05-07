import 'package:flutter/material.dart';

class ProfileViewScreen extends StatelessWidget {
  final Map<String, dynamic> profileData;
  const ProfileViewScreen({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(profileData['stage_name'] ?? profileData['full_name'] ?? 'Portfolio'),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            _buildProfileHeader(),
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info_outline), text: 'Details'),
                Tab(icon: Icon(Icons.grid_on), text: 'Portfolio'),
              ],
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.grey,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDetailsTab(),
                  _buildPortfolioGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.amber,
            child: Icon(Icons.person, size: 40, color: Colors.black),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileData['full_name'] ?? 'Professional',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  profileData['skills'] ?? 'Film Industry',
                  style: const TextStyle(color: Colors.amber, fontSize: 16),
                ),
                const SizedBox(height: 4),
                // Displaying the Rating System we discussed
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${profileData['rating'] ?? 'New'} • ${profileData['location_area'] ?? 'Chennai'}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection("Stage Name", profileData['stage_name'] ?? 'N/A'),
          _buildInfoSection("Experience", profileData['experience'] ?? 'Fresher'),
          _buildInfoSection("Bio", profileData['bio'] ?? 'Dedicated film professional. Looking for meaningful collaborations in the industry.'),
          const SizedBox(height: 30),
          // Contact Button with the "Trust Disclaimer"
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // We will add the T&C and WhatsApp launch logic here
            },
            child: const Text(
              "CONTACT FOR COLLAB",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPortfolioGrid() {
    // This is the "Instagram-style" grid
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 12, // This will eventually pull from your 'posts' table
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[900],
          child: const Icon(Icons.image, color: Colors.white24),
        );
      },
    );
  }
}