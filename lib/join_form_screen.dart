import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client_provider.dart';
import 'portfolio_screen.dart';
import 'location_service.dart';
import 'discover_screen.dart';

class JoinFormScreen extends ConsumerStatefulWidget {
  const JoinFormScreen({super.key});

  @override
  ConsumerState<JoinFormScreen> createState() => _JoinFormScreenState();
}

class _JoinFormScreenState extends ConsumerState<JoinFormScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _stageNameController = TextEditingController();
  final TextEditingController _instaController = TextEditingController();
  final TextEditingController _ytController = TextEditingController();

  // THE CORE VARIABLES
  List<String> _selectedRoles = [];
  String _detectedLocation = "Fetching location...";
  String _selectedExperience = 'Fresher';

  final List<String> _roles = [
    'Actor/Actress', 'Director', 'Camera Man', 'Editors',
    'Scriptwriter', 'Music Director', 'Location Owner',
    'Accessories', 'Costume Designer', 'Dubbing Artist', 'Lyricist'
  ];

  @override
  void initState() {
    super.initState();
    _initLocation(); // Automatically starts GPS on page load
  }

  Future<void> _initLocation() async {
    String loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() => _detectedLocation = loc);
    }
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() => _imageFile = selected);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _stageNameController.dispose();
    _instaController.dispose();
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CiniFind: REGISTER",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PHOTO SECTION
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white10,
                  backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.add_a_photo, color: Colors.amber, size: 35)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text("PERSONAL DETAILS", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField("Full Name (Compulsory)", _fullNameController),
            const SizedBox(height: 15),
            _buildTextField("Stage Name (Compulsory)", _stageNameController),

            const SizedBox(height: 30),
            const Text("PROFESSIONAL SELECTION", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 2. MULTI-ROLE CHIPS (MAX 3)
            const Text("Choose up to 3 Roles", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _roles.map((role) {
                final isSelected = _selectedRoles.contains(role);
                return FilterChip(
                  label: Text(role, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                  selected: isSelected,
                  selectedColor: Colors.amber,
                  checkmarkColor: Colors.black,
                  backgroundColor: Colors.white10,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedRoles.length < 3) {
                          _selectedRoles.add(role);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("You can only select up to 3 roles"))
                          );
                        }
                      } else {
                        _selectedRoles.remove(role);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 3. AUTO GPS DISPLAY
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.my_location, color: Colors.amber),
              title: Text(_detectedLocation, style: const TextStyle(color: Colors.white)),
              subtitle: const Text("GPS Detected Area", style: TextStyle(color: Colors.white54, fontSize: 11)),
            ),

            const SizedBox(height: 15),
            _buildDropdown("Experience", ['Fresher', '1-2 Projects', 'Professional'],
                    (val) => setState(() => _selectedExperience = val!), _selectedExperience),

            const SizedBox(height: 30),
            _buildTextField("Instagram URL (Optional)", _instaController),
            const SizedBox(height: 15),
            _buildTextField("YouTube Work Link (Optional)", _ytController),

            const SizedBox(height: 40),

            // 4. CREATE PROFILE BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () async {
                final supabase = ref.read(supabaseClientProvider);

                if (_fullNameController.text.isEmpty || _stageNameController.text.isEmpty || _selectedRoles.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all compulsory fields")));
                  return;
                }

                final user = supabase.auth.currentUser;
                if (user == null) return;

                try {
                  String? imageUrl;
                  if (_imageFile != null) {
                    final fileName = '${user.id}.jpg';
                    final file = File(_imageFile!.path);
                    await supabase.storage.from('avatars').upload(fileName, file, fileOptions: const FileOptions(upsert: true));
                    imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
                  }

                  // Joining the list into a string for the Portfolio "roleType"
                  String rolesString = _selectedRoles.join(', ');

                  await supabase.from('profiles').upsert({
                    'id': user.id,
                    'full_name': _fullNameController.text,
                    'stage_name': _stageNameController.text,
                    'role_type': rolesString,
                    'location_area': _detectedLocation,
                    'experience_level': _selectedExperience,
                    'instagram_url': _instaController.text,
                    'youtube_url': _ytController.text,
                    'avatar_url': imageUrl,
                  });

                  if (!mounted) return;

                  // Move to Portfolio Screen
                  context.go('/home');
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save Error: $e")));
                }
              },
              child: const Text("CREATE PROFILE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        filled: true,
        fillColor: Colors.white10,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged, String currentVal) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.grey[900],
      value: currentVal,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.amber)),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }
}