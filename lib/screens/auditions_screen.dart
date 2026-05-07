import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuditionsScreen extends StatefulWidget {
  const AuditionsScreen({super.key});

  @override
  State<AuditionsScreen> createState() => _AuditionsScreenState();
}

class _AuditionsScreenState extends State<AuditionsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _auditions = [];

  @override
  void initState() {
    super.initState();
    _fetchAuditions();
  }

  Future<void> _fetchAuditions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await Supabase.instance.client
          .from('auditions')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _auditions = data.map((row) => Map<String, dynamic>.from(row)).toList();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load auditions: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCreateAuditionSheet() async {
    final titleController = TextEditingController();
    final roleController = TextEditingController();
    final locationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId == null) {
                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Please log in to post an audition.')),
                );
                return;
              }

              setSheetState(() => isSubmitting = true);
              try {
                await Supabase.instance.client.from('auditions').insert({
                  'title': titleController.text.trim(),
                  'role_needed': roleController.text.trim(),
                  'location': locationController.text.trim(),
                  'posted_by': userId,
                });

                if (!mounted) return;
                Navigator.of(context).pop();
                await _fetchAuditions();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Failed to create audition: $e')),
                );
              } finally {
                if (mounted) {
                  setSheetState(() => isSubmitting = false);
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create Audition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: roleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Role needed',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Role needed is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Location is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isSubmitting ? null : submit,
                      icon: const Icon(Icons.add),
                      label: Text(isSubmitting ? 'Posting...' : 'Post Audition'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    roleController.dispose();
    locationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D0D0D);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Auditions'),
        backgroundColor: bg,
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
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _auditions.length,
                  itemBuilder: (context, index) {
                    final item = _auditions[index];
                    final title = (item['title'] ?? '').toString();
                    final role = (item['role_needed'] ?? '').toString();
                    final location = (item['location'] ?? '').toString();
                    final postedBy = (item['posted_by'] ?? '').toString();

                    return Card(
                      color: Colors.white10,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          title.isEmpty ? 'Untitled Audition' : title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text('Role: $role', style: const TextStyle(color: Colors.white70)),
                            Text('Location: $location',
                                style: const TextStyle(color: Colors.white70)),
                            Text('Posted by: $postedBy',
                                style: const TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateAuditionSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

