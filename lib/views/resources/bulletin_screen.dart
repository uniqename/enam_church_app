import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class BulletinScreen extends StatefulWidget {
  const BulletinScreen({super.key});

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _bulletin;
  AppUser? _currentUser;

  static const _localKey = 'local_bulletin_v2';

  static final _defaultBulletin = {
    'title': 'Sunday Service',
    'date': DateTime.now().toIso8601String(),
    'scripture': 'Psalm 100:2 — Serve the Lord with gladness; come before His presence with singing.',
    'items': [
      {'time': '9:00 AM', 'title': 'Praise & Worship', 'leader': 'Worship Team', 'icon': 'music_note'},
      {'time': '9:25 AM', 'title': 'Welcome & Announcements', 'leader': 'Host Pastor', 'icon': 'announcement'},
      {'time': '9:35 AM', 'title': 'Prayer & Intercession', 'leader': 'Prayer Team', 'icon': 'favorite'},
      {'time': '9:50 AM', 'title': 'Tithes & Offering', 'leader': 'Deacons', 'icon': 'monetization_on'},
      {'time': '10:00 AM', 'title': 'Word of God / Sermon', 'leader': 'Senior Pastor', 'icon': 'menu_book'},
      {'time': '10:45 AM', 'title': 'Altar Call & Ministry', 'leader': 'Ministry Team', 'icon': 'church'},
      {'time': '11:00 AM', 'title': 'Benediction & Dismissal', 'leader': 'Pastor', 'icon': 'handshake'},
    ],
    'announcements': [
      'New Members Class — Every 1st Sunday after service',
      'Mid-week Bible Study — Wednesdays at 7:00 PM',
      'Prayer Night — Fridays at 8:00 PM',
      'Youth Service — Saturdays at 4:00 PM',
    ],
  };

  static final Map<String, IconData> _iconMap = {
    'music_note': Icons.music_note,
    'announcement': Icons.campaign,
    'favorite': Icons.favorite,
    'monetization_on': Icons.monetization_on,
    'menu_book': Icons.menu_book,
    'church': Icons.church,
    'handshake': Icons.handshake,
    'people': Icons.people,
    'star': Icons.star,
    'volunteer_activism': Icons.volunteer_activism,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final user = await AuthService().getCurrentUserProfile();
    Map<String, dynamic>? bulletin;

    // Try Supabase first
    try {
      final results = await SupabaseService().query('bulletins', column: 'active', value: true);
      if (results.isNotEmpty) bulletin = results.first;
    } catch (_) {}

    // Fall back to local saved bulletin
    if (bulletin == null) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localKey);
      if (raw != null) {
        bulletin = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      }
    }

    setState(() {
      _bulletin = bulletin ?? Map<String, dynamic>.from(_defaultBulletin);
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _saveBulletinLocally() async {
    if (_bulletin == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(_bulletin));
  }

  bool get _canEdit => _currentUser?.canManageContent ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Bulletin'),
        actions: [
          if (_canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: 'Edit Bulletin',
              onPressed: () => _showBulletinEditor(context),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: 'Publish Bulletin',
              onPressed: () => _publishBulletin(context),
            ),
          ],
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
                    _buildOrderOfService(),
                    const SizedBox(height: 24),
                    _buildAnnouncements(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final dateStr = _bulletin?['date'] != null
        ? DateFormat('EEEE, MMMM d, yyyy').format(
            DateTime.tryParse(_bulletin!['date'].toString()) ?? DateTime.now(),
          )
        : DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.church, color: Colors.white, size: 36),
          const SizedBox(height: 10),
          Text(
            _bulletin?['title'] as String? ?? 'Sunday Service',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(dateStr, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          if (_bulletin?['scripture'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"${_bulletin!['scripture']}"',
                style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderOfService() {
    final items = _bulletin?['items'];
    if (items == null) return const SizedBox.shrink();
    final List<dynamic> serviceItems = items is List ? items : (items as Map).values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Order of Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_canEdit) ...[
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Item'),
                onPressed: () => _showItemDialog(context, null),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...serviceItems.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value as Map<dynamic, dynamic>;
          final icon = _iconMap[item['icon'] as String? ?? 'church'] ?? Icons.circle;
          final isLast = i == serviceItems.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.purple.withOpacity(0.4)),
                      ),
                      child: Icon(icon, size: 18, color: AppColors.purple),
                    ),
                    if (!isLast)
                      Expanded(child: Container(width: 2, color: AppColors.purple.withOpacity(0.2))),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(item['title'] as String? ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ),
                                  if (item['time'] != null)
                                    Text(item['time'] as String,
                                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55), fontWeight: FontWeight.w500)),
                                ],
                              ),
                              if (item['leader'] != null)
                                Text(item['leader'] as String,
                                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.48))),
                            ],
                          ),
                        ),
                        if (_canEdit)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _showItemDialog(context, i),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.edit, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                                ),
                              ),
                              InkWell(
                                onTap: () => _deleteServiceItem(i),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnnouncements() {
    final announcements = _bulletin?['announcements'];
    if (announcements == null) return const SizedBox.shrink();
    final List<dynamic> items = announcements is List ? announcements : (announcements as Map).values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Announcements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_canEdit) ...[
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                onPressed: () => _showAnnouncementDialog(context, null),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.blue.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.campaign, color: AppColors.blue, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(e.value.toString(), style: const TextStyle(fontSize: 14, height: 1.4))),
              if (_canEdit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _showAnnouncementDialog(context, e.key),
                      child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.edit, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
                    ),
                    InkWell(
                      onTap: () => _deleteAnnouncement(e.key),
                      child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.delete_outline, size: 16, color: Colors.red)),
                    ),
                  ],
                ),
            ],
          ),
        )),
      ],
    );
  }

  // ─── Edit dialogs ────────────────────────────────────────────────────────────

  Future<void> _showBulletinEditor(BuildContext context) async {
    final titleCtrl = TextEditingController(text: _bulletin?['title'] as String? ?? '');
    final scriptureCtrl = TextEditingController(text: _bulletin?['scripture'] as String? ?? '');
    DateTime selectedDate = _bulletin?['date'] != null
        ? DateTime.tryParse(_bulletin!['date'].toString()) ?? DateTime.now()
        : DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setFormState) => AlertDialog(
          title: const Text('Edit Bulletin Header'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Service Title')),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setFormState(() => selectedDate = d);
                },
              ),
              TextField(
                controller: scriptureCtrl,
                decoration: const InputDecoration(labelText: 'Scripture of the Day'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() {
                  _bulletin!['title'] = titleCtrl.text.trim();
                  _bulletin!['scripture'] = scriptureCtrl.text.trim();
                  _bulletin!['date'] = selectedDate.toIso8601String();
                });
                await _saveBulletinLocally();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showItemDialog(BuildContext context, int? idx) async {
    final items = List<Map<String, dynamic>>.from(
      (_bulletin?['items'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final existing = idx != null ? items[idx] : <String, dynamic>{};
    final timeCtrl = TextEditingController(text: existing['time'] as String? ?? '');
    final titleCtrl = TextEditingController(text: existing['title'] as String? ?? '');
    final leaderCtrl = TextEditingController(text: existing['leader'] as String? ?? '');
    String selectedIcon = existing['icon'] as String? ?? 'church';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setFormState) => AlertDialog(
          title: Text(idx == null ? 'Add Service Item' : 'Edit Service Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time (e.g. 9:00 AM)')),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Item Title *')),
              TextField(controller: leaderCtrl, decoration: const InputDecoration(labelText: 'Led By')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedIcon,
                decoration: const InputDecoration(labelText: 'Icon'),
                items: _iconMap.entries.map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Row(children: [Icon(e.value, size: 18), const SizedBox(width: 8), Text(e.key)]),
                )).toList(),
                onChanged: (v) { if (v != null) setFormState(() => selectedIcon = v); },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final entry = {
                  'time': timeCtrl.text.trim(),
                  'title': titleCtrl.text.trim(),
                  'leader': leaderCtrl.text.trim(),
                  'icon': selectedIcon,
                };
                if (idx == null) items.add(entry); else items[idx] = entry;
                setState(() => _bulletin!['items'] = items);
                await _saveBulletinLocally();
              },
              child: Text(idx == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteServiceItem(int idx) {
    final items = List<dynamic>.from(_bulletin?['items'] as List<dynamic>? ?? []);
    items.removeAt(idx);
    setState(() => _bulletin!['items'] = items);
    _saveBulletinLocally();
  }

  Future<void> _showAnnouncementDialog(BuildContext context, int? idx) async {
    final announcements = List<String>.from(
      (_bulletin?['announcements'] as List<dynamic>? ?? []).map((e) => e.toString()),
    );
    final ctrl = TextEditingController(text: idx != null ? announcements[idx] : '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(idx == null ? 'Add Announcement' : 'Edit Announcement'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Announcement'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              if (idx == null) announcements.add(ctrl.text.trim());
              else announcements[idx] = ctrl.text.trim();
              setState(() => _bulletin!['announcements'] = announcements);
              await _saveBulletinLocally();
            },
            child: Text(idx == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteAnnouncement(int idx) {
    final announcements = List<dynamic>.from(_bulletin?['announcements'] as List<dynamic>? ?? []);
    announcements.removeAt(idx);
    setState(() => _bulletin!['announcements'] = announcements);
    _saveBulletinLocally();
  }

  Future<void> _publishBulletin(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish Bulletin'),
        content: const Text(
          'This will save the bulletin as the active bulletin for all members. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    await _saveBulletinLocally();

    // Also try to push to Supabase
    if (SupabaseService.isConfigured && _bulletin != null) {
      try {
        final data = Map<String, dynamic>.from(_bulletin!);
        data['active'] = true;
        data['published_at'] = DateTime.now().toIso8601String();
        await SupabaseService().create('bulletins', data);
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bulletin published!'), backgroundColor: AppColors.success),
      );
    }
  }
}
