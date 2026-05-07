import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'discover_screen.dart';
import 'portfolio_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();

  // Logic for Location Tab (Map & Details)
  Future<void> _handleLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition();
    print("Coordinates: ${position.latitude}, ${position.longitude}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location details captured via GPS")),
    );
  }

  // Logic for Accessories/Profile Gallery
  Future<void> _handleMedia() async {
    final XFile? media = await _picker.pickMedia(); // Allows both image and video
    if (media != null) {
      print("Media Path: ${media.path}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Media Added: ${media.name}")),
      );
    }
  }

  late final List<Widget> _screens = [
    const DiscoverScreen(),
    _buildLocationTab(),
    _buildAccessoriesTab(),
    const PortfolioScreen(), // Keep strictly for Insta/YouTube URLs
    _buildProfileTab(),      // Identity: Name, Stage Name, Contact, Image
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Loc'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Acc'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return _buildEntryLayout(
      title: "REGISTER LOCATION",
      btnLabel: "GET LOCATION FROM MAP",
      onBtnPressed: _handleLocation,
      fields: ["Rent per Day", "Description"],
    );
  }

  Widget _buildAccessoriesTab() {
    return _buildEntryLayout(
      title: "ADD ACCESSORIES",
      btnLabel: "ADD ACC FIRST",
      onBtnPressed: _handleMedia,
      fields: ["Condition", "Rent Price"],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _handleMedia,
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white10,
              child: Icon(Icons.add_a_photo, color: Colors.amber),
            ),
          ),
          const SizedBox(height: 20),
          _buildField("Full Name"),
          _buildField("Stage Name"),
          _buildField("Mobile Number"),
          _buildField("Email ID"),
          _buildField("Location"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: const Text("UPDATE IDENTITY"),
          )
        ],
      ),
    );
  }

  Widget _buildEntryLayout({required String title, required String btnLabel, required VoidCallback onBtnPressed, required List<String> fields}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text(title, style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...fields.map((f) => _buildField(f)),
          const Text("Add Images/Videos", style: TextStyle(color: Colors.white54)),
          IconButton(onPressed: _handleMedia, icon: const Icon(Icons.add_to_photos, color: Colors.amber, size: 40)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBtnPressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              child: Text(btnLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        ),
      ),
    );
  }
}