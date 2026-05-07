import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _bioController = TextEditingController();
  final _picker = ImagePicker();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false;
  String? _error;
  Map<String, dynamic>? _profile;
  String? _avatarUrl;

  bool get _isOwnProfile {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return currentUserId != null && currentUserId == widget.userId;
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', widget.userId)
          .single();

      final profile = Map<String, dynamic>.from(data);
      _profile = profile;
      _avatarUrl = profile['avatar_url']?.toString();
      _bioController.text = profile['bio']?.toString() ?? '';
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isSaving = true);
    try {
      final extension = picked.path.split('.').last.toLowerCase();
      final fileName = '${widget.userId}_${const Uuid().v4()}.$extension';
      final file = File(picked.path);

      await Supabase.instance.client.storage.from('avatars').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);

      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_url': publicUrl}).eq('id', widget.userId);

      setState(() {
        _avatarUrl = publicUrl;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update photo: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveBio() async {
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.from('profiles').update({
        'bio': _bioController.text.trim(),
      }).eq('id', widget.userId);

      setState(() {
        _isEditMode = false;
        _profile = {
          ...?_profile,
          'bio': _bioController.text.trim(),
        };
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildAvatar() {
    if (_avatarUrl == null || _avatarUrl!.isEmpty) {
      return const CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white12,
        child: Icon(Icons.person, color: Colors.white70, size: 44),
      );
    }

    return CachedNetworkImage(
      imageUrl: _avatarUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 48,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => const CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white12,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (context, url, error) => const CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white12,
        child: Icon(Icons.person, color: Colors.white70, size: 44),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D0D0D);
    const gold = Color(0xFFF5C518);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: bg,
        actions: [
          if (_isOwnProfile && !_isLoading)
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() => _isEditMode = !_isEditMode);
                    },
              child: Text(
                _isEditMode ? 'Cancel' : 'Edit',
                style: const TextStyle(color: gold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            _buildAvatar(),
                            if (_isOwnProfile && _isEditMode)
                              FloatingActionButton.small(
                                onPressed: _isSaving ? null : _pickAndUploadAvatar,
                                backgroundColor: gold,
                                foregroundColor: Colors.black,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.camera_alt),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (_profile?['full_name'] ?? 'Unknown User').toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (_profile?['role'] ?? _profile?['role_type'] ?? 'Unknown Role')
                                .toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _bioController,
                        enabled: _isOwnProfile && _isEditMode && !_isSaving,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          labelStyle: TextStyle(color: Colors.white70),
                          alignLabelWithHint: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: gold),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                      if (_isOwnProfile && _isEditMode) ...[
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveBio,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save Changes'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

