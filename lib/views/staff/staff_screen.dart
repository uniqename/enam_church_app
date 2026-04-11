import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  static const _cacheKey = 'staff_members_v3';

  List<Map<String, dynamic>> _staff = [];
  AppUser? _currentUser;
  bool _isLoading = true;

  static final List<Map<String, dynamic>> _defaultStaff = [
    {
      'id': 'staff-1',
      'name': 'Rev. Ebenezer Adarquah-Yiadom',
      'title': 'Senior Pastor & Founder',
      'bio': 'The founding pastor of Faith Klinik Ministries, called to build a community rooted in faith, healing, and transformation in Columbus, Ohio.',
      'email': 'pastor@faithklinikministries.com',
      'department': 'Leadership',
      'photo_url': '',
    },
    {
      'id': 'staff-2',
      'name': 'Rev. Lucie Adarquah-Yiadom',
      'title': 'Associate Pastor & Women\'s Ministry Leader',
      'bio': 'Oversees congregational care, women\'s ministry, and children\'s ministry.',
      'email': 'associate@faithklinikministries.com',
      'department': 'Leadership',
      'photo_url': '',
    },
    {
      'id': 'staff-3',
      'name': 'Gloria Adarquah-Yiadom',
      'title': 'Prayer Ministry Leader',
      'bio': 'Leads the intercessory prayer team, cultivating a culture of prayer at Faith Klinik.',
      'email': 'prayer@faithklinikministries.com',
      'department': 'Prayer Ministry',
      'photo_url': '',
    },
    {
      'id': 'staff-4',
      'name': 'Jeshurun Adarquah-Yiadom',
      'title': 'Youth Ministry Leader',
      'bio': 'Passionate about equipping the next generation with a solid biblical foundation.',
      'email': 'youth@faithklinikministries.com',
      'department': 'Youth Ministry',
      'photo_url': '',
    },
    {
      'id': 'staff-5',
      'name': 'Jedidiah Adarquah-Yiadom',
      'title': 'Worship & League of Anointed Ministers',
      'bio': 'Leads the League of Anointed Ministers, overseeing worship and music ministry.',
      'email': 'worship@faithklinikministries.com',
      'department': 'League of Anointed Ministers',
      'photo_url': '',
    },
    {
      'id': 'staff-6',
      'name': 'Enam Egyir',
      'title': 'Dance Ministry Leader',
      'bio': 'Leads the Faith Klinik Dance Ministers, using creative arts and movement as an expression of worship.',
      'email': 'dance@faithklinikministries.com',
      'department': 'Faith Klinik Dance Ministers',
      'photo_url': '',
    },
    {
      'id': 'staff-7',
      'name': 'Deaconess Esinam Segoh',
      'title': 'Ushering & Food Pantry Ministry Leader',
      'bio': 'Leads the ushering department and oversees the Food Pantry Ministry, serving the Columbus community.',
      'email': 'foodpantry@faithklinikministries.com',
      'department': 'Food Pantry Ministry',
      'photo_url': '',
    },
    {
      'id': 'staff-8',
      'name': 'Jasper D.',
      'title': 'Media Ministry Leader',
      'bio': 'Leads the Media Ministry team, managing livestreams, photography, video production, and social media.',
      'email': 'media@faithklinikministries.com',
      'department': 'Media Ministry',
      'photo_url': '',
    },
  ];

  static const List<Color> _colors = [
    AppColors.purple, AppColors.blue, Color(0xFF6A0080), AppColors.accentBlue,
    AppColors.success, Color(0xFFE65100), Color(0xFF00695C), Color(0xFF1565C0),
    Color(0xFF4A148C), Color(0xFF006064),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final user = await AuthService().getCurrentUserProfile();

    // Try Supabase first
    try {
      final rows = await SupabaseService().query('staff_members', orderBy: 'sort_order', ascending: true);
      if (rows.isNotEmpty) {
        setState(() { _staff = List<Map<String, dynamic>>.from(rows); _currentUser = user; _isLoading = false; });
        // Cache locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(_staff));
        return;
      }
    } catch (_) {}

    // Fall back to local cache, then defaults
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      final staff = raw != null
          ? List<Map<String, dynamic>>.from(jsonDecode(raw) as List)
          : List<Map<String, dynamic>>.from(_defaultStaff);
      setState(() { _staff = staff; _currentUser = user; _isLoading = false; });
    } catch (_) {
      setState(() { _staff = List<Map<String, dynamic>>.from(_defaultStaff); _currentUser = user; _isLoading = false; });
    }
  }

  Future<void> _saveAll() async {
    // Save to Supabase
    try {
      for (int i = 0; i < _staff.length; i++) {
        final entry = Map<String, dynamic>.from(_staff[i]);
        entry['sort_order'] = i;
        final id = entry['id'] as String? ?? '';
        if (id.startsWith('staff-')) {
          // Default/new entry — try upsert
          await SupabaseService().insert('staff_members', entry);
        } else {
          await SupabaseService().update('staff_members', id, entry);
        }
      }
    } catch (_) {}
    // Always cache locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(_staff));
  }

  Future<String?> _uploadPhoto(String staffId, File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final path = 'staff/$staffId.$ext';
    try {
      return await SupabaseService().uploadImage('church-media', path, file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Photo upload failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ));
      }
      return null;
    }
  }

  bool get _canEdit => _currentUser?.canManageContent ?? false;

  Color _colorFor(int i) => _colors[i % _colors.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Team'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Add Team Member',
              onPressed: () => _showEditDialog(null),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    ..._staff.asMap().entries.map((e) => _buildCard(e.value, e.key)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple.withValues(alpha: 0.12), AppColors.blue.withValues(alpha: 0.06)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.church, size: 44, color: AppColors.purple),
          const SizedBox(height: 8),
          const Text('Leadership & Ministry Team',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.purple),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('${_staff.length} team members',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> member, int idx) {
    final color = _colorFor(idx);
    final photoUrl = member['photo_url'] as String? ?? '';
    final name = member['name'] as String? ?? '';
    final initials = name.trim().split(' ')
        .where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo / initials avatar ────────────────────────────────────
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.15),
              backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.isEmpty
                  ? Text(initials,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      if (_canEdit) ...[
                        InkWell(
                          onTap: () => _showEditDialog(idx),
                          child: const Icon(Icons.edit, size: 18, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _confirmDelete(idx),
                          child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                  Text(member['title'] as String? ?? '',
                      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                  if ((member['department'] as String? ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(member['department'] as String,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ),
                  const SizedBox(height: 8),
                  Text(member['bio'] as String? ?? '',
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                  if ((member['email'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(member['email'] as String,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(int? idx) async {
    final existing = idx != null ? Map<String, dynamic>.from(_staff[idx]) : <String, dynamic>{};
    final nameCtrl = TextEditingController(text: existing['name'] as String? ?? '');
    final titleCtrl = TextEditingController(text: existing['title'] as String? ?? '');
    final bioCtrl = TextEditingController(text: existing['bio'] as String? ?? '');
    final emailCtrl = TextEditingController(text: existing['email'] as String? ?? '');
    final deptCtrl = TextEditingController(text: existing['department'] as String? ?? '');
    String photoUrl = existing['photo_url'] as String? ?? '';
    File? pickedPhoto;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(idx == null ? 'Add Team Member' : 'Edit Team Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Photo picker ──────────────────────────────────────────
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (picked != null) {
                      setS(() => pickedPhoto = File(picked.path));
                    }
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.purple.withValues(alpha: 0.12),
                        backgroundImage: pickedPhoto != null
                            ? FileImage(pickedPhoto!)
                            : (photoUrl.isNotEmpty ? NetworkImage(photoUrl) as ImageProvider : null),
                        child: (pickedPhoto == null && photoUrl.isEmpty)
                            ? const Icon(Icons.person, size: 40, color: AppColors.purple)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Tap photo to change',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title / Role *', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: deptCtrl,
                    decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                TextField(controller: bioCtrl,
                    decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
                    maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);

                final staffId = (existing['id'] as String?)?.isNotEmpty == true
                    ? existing['id'] as String
                    : 'staff-${DateTime.now().millisecondsSinceEpoch}';

                // Upload photo if one was picked
                if (pickedPhoto != null) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(const SnackBar(
                      content: Text('Uploading photo…'), duration: Duration(seconds: 30)));
                  final uploaded = await _uploadPhoto(staffId, pickedPhoto!);
                  messenger.hideCurrentSnackBar();
                  if (uploaded != null) photoUrl = uploaded;
                }

                final entry = {
                  'id': staffId,
                  'name': nameCtrl.text.trim(),
                  'title': titleCtrl.text.trim(),
                  'bio': bioCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'department': deptCtrl.text.trim(),
                  'photo_url': photoUrl,
                };
                setState(() {
                  if (idx == null) _staff.add(entry); else _staff[idx] = entry;
                });
                await _saveAll();
              },
              child: Text(idx == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int idx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Team Member'),
        content: Text('Remove ${_staff[idx]['name']} from the team list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final id = _staff[idx]['id'] as String? ?? '';
      // Remove from Supabase if it's a real UUID
      if (!id.startsWith('staff-')) {
        try { await SupabaseService().delete('staff_members', id); } catch (_) {}
      }
      setState(() => _staff.removeAt(idx));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(_staff));
    }
  }
}
