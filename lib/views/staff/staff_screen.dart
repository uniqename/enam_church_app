import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  static const _prefsKey = 'staff_members_v2';
  List<Map<String, dynamic>> _staff = [];
  AppUser? _currentUser;
  bool _isLoading = true;

  static final List<Map<String, dynamic>> _defaultStaff = [
    {
      'id': 'staff-1',
      'name': 'Rev. Ebenezer Adarquah-Yiadom',
      'title': 'Senior Pastor & Founder',
      'bio': 'The founding pastor of Faith Klinik Ministries, called to build a community rooted in faith, healing, and transformation in Columbus, Ohio. A visionary leader who believes in restoring lives through the power of God\'s Word.',
      'email': 'pastor@faithklinikministries.com',
      'phone': '',
      'department': 'Leadership',
      'icon': 'church',
    },
    {
      'id': 'staff-2',
      'name': 'Rev. Lucie Adarquah-Yiadom',
      'title': 'Associate Pastor & Women\'s Ministry Leader',
      'bio': 'Oversees congregational care, women\'s ministry, and children\'s ministry. Dedicated to shepherding members through every season of life with compassion and wisdom.',
      'email': 'associate@faithklinikministries.com',
      'phone': '',
      'department': 'Leadership',
      'icon': 'people_alt',
    },
    {
      'id': 'staff-3',
      'name': 'Gloria Adarquah-Yiadom',
      'title': 'Prayer Ministry Leader',
      'bio': 'Leads the intercessory prayer team, cultivating a culture of prayer and spiritual warfare at Faith Klinik. Organizes prayer nights and coordinates the prayer chain.',
      'email': 'prayer@faithklinikministries.com',
      'phone': '',
      'department': 'Prayer Ministry',
      'icon': 'favorite',
    },
    {
      'id': 'staff-4',
      'name': 'Jeshurun Adarquah-Yiadom',
      'title': 'Youth Ministry Leader',
      'bio': 'Passionate about equipping the next generation with a solid biblical foundation. Leads youth service every Saturday and empowers young people to live out their faith boldly.',
      'email': 'youth@faithklinikministries.com',
      'phone': '',
      'department': 'Youth Ministry',
      'icon': 'groups',
    },
    {
      'id': 'staff-5',
      'name': 'Jedidiah Adarquah-Yiadom',
      'title': 'Worship & League of Anointed Ministers',
      'bio': 'Leads the League of Anointed Ministers, overseeing worship and music ministry. Creates an atmosphere of genuine encounter with God through anointed praise and worship.',
      'email': 'worship@faithklinikministries.com',
      'phone': '',
      'department': 'League of Anointed Ministers',
      'icon': 'music_note',
    },
    {
      'id': 'staff-6',
      'name': 'Enam Egyir',
      'title': 'Dance Ministry Leader',
      'bio': 'Leads the Faith Klinik Dance Ministers, using creative arts and movement as an expression of worship and ministry. Choreographs dance performances for church services and special events.',
      'email': 'dance@faithklinikministries.com',
      'phone': '',
      'department': 'Faith Klinik Dance Ministers',
      'icon': 'self_improvement',
    },
    {
      'id': 'staff-7',
      'name': 'Deaconess Esinam Segoh',
      'title': 'Ushering & Food Pantry Ministry Leader',
      'bio': 'Leads the ushering department and oversees the Food Pantry Ministry, serving the Columbus community with practical assistance. Coordinates volunteers and manages food distribution operations.',
      'email': 'foodpantry@faithklinikministries.com',
      'phone': '',
      'department': 'Food Pantry Ministry',
      'icon': 'volunteer_activism',
    },
    {
      'id': 'staff-8',
      'name': 'Jasper D.',
      'title': 'Media Ministry Leader',
      'bio': 'Leads the Media Ministry team, managing livestreams, photography, video production, and social media presence for Faith Klinik Ministries.',
      'email': 'media@faithklinikministries.com',
      'phone': '',
      'department': 'Media Ministry',
      'icon': 'videocam',
    },
    {
      'id': 'staff-9',
      'name': 'Eyram Kwauvi',
      'title': 'Dance Ministry — Lead Dancer',
      'bio': 'A core member of the Faith Klinik Dance Ministers, bringing grace and excellence to every performance. Serves as a lead dancer and mentor to newer dance team members.',
      'email': '',
      'phone': '',
      'department': 'Faith Klinik Dance Ministers',
      'icon': 'self_improvement',
    },
    {
      'id': 'staff-10',
      'name': 'Edem Kwauvi',
      'title': 'Dance Ministry — Dancer',
      'bio': 'Member of the Faith Klinik Dance Ministers, serving faithfully in dance worship ministry.',
      'email': '',
      'phone': '',
      'department': 'Faith Klinik Dance Ministers',
      'icon': 'self_improvement',
    },
  ];

  static const Map<String, IconData> _iconMap = {
    'church': Icons.church,
    'people_alt': Icons.people_alt,
    'favorite': Icons.favorite,
    'groups': Icons.groups,
    'music_note': Icons.music_note,
    'self_improvement': Icons.self_improvement,
    'volunteer_activism': Icons.volunteer_activism,
    'videocam': Icons.videocam,
    'person': Icons.person,
  };

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
    final user = await AuthService().getCurrentUserProfile();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final staff = raw != null
        ? List<Map<String, dynamic>>.from(jsonDecode(raw) as List)
        : List<Map<String, dynamic>>.from(_defaultStaff);
    setState(() { _staff = staff; _currentUser = user; _isLoading = false; });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_staff));
  }

  bool get _canEdit => _currentUser?.canManageContent ?? false;

  Color _colorFor(int i) => _colors[i % _colors.length];

  IconData _iconFor(String? key) => _iconMap[key] ?? Icons.person;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Team'),
        actions: [
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Add Team Member',
              onPressed: () => _showEditDialog(context, null),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  ..._staff.asMap().entries.map((e) =>
                    _buildCard(context, e.value, e.key)),
                ],
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
          colors: [AppColors.purple.withOpacity(0.12), AppColors.blue.withOpacity(0.06)],
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

  Widget _buildCard(BuildContext context, Map<String, dynamic> member, int idx) {
    final color = _colorFor(idx);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(_iconFor(member['icon'] as String?), color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(member['name'] as String? ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      if (_canEdit) ...[
                        InkWell(
                          onTap: () => _showEditDialog(context, idx),
                          child: const Icon(Icons.edit, size: 18, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _confirmDelete(context, idx),
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
                        Text(member['email'] as String,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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

  Future<void> _showEditDialog(BuildContext context, int? idx) async {
    final existing = idx != null ? Map<String, dynamic>.from(_staff[idx]) : <String, dynamic>{};
    final nameCtrl = TextEditingController(text: existing['name'] as String? ?? '');
    final titleCtrl = TextEditingController(text: existing['title'] as String? ?? '');
    final bioCtrl = TextEditingController(text: existing['bio'] as String? ?? '');
    final emailCtrl = TextEditingController(text: existing['email'] as String? ?? '');
    final deptCtrl = TextEditingController(text: existing['department'] as String? ?? '');
    String selectedIcon = existing['icon'] as String? ?? 'person';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setFormState) => AlertDialog(
          title: Text(idx == null ? 'Add Team Member' : 'Edit Team Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title / Role *')),
                TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 3),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedIcon,
                  decoration: const InputDecoration(labelText: 'Icon'),
                  items: _iconMap.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(children: [Icon(e.value, size: 20), const SizedBox(width: 8), Text(e.key)]),
                  )).toList(),
                  onChanged: (v) { if (v != null) setFormState(() => selectedIcon = v); },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final entry = {
                  'id': existing['id'] ?? 'staff-${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text.trim(),
                  'title': titleCtrl.text.trim(),
                  'bio': bioCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'department': deptCtrl.text.trim(),
                  'icon': selectedIcon,
                };
                setState(() {
                  if (idx == null) _staff.add(entry); else _staff[idx] = entry;
                });
                await _save();
              },
              child: Text(idx == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int idx) async {
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
      setState(() => _staff.removeAt(idx));
      await _save();
    }
  }
}
