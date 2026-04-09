import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _auth = AuthService();
  final _supabase = SupabaseService();

  List<Map<String, dynamic>> _notes = [];
  bool _loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _userId = await _auth.getCurrentUserId();
      if (_userId != null) {
        final data = await _supabase.client
            .from('member_notes')
            .select()
            .eq('user_id', _userId!)
            .order('updated_at', ascending: false);
        setState(() {
          _notes = List<Map<String, dynamic>>.from(data as List);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _showNoteForm([Map<String, dynamic>? existing]) async {
    final sermonTitleCtrl = TextEditingController(text: existing?['sermon_title'] ?? '');
    final keyPassageCtrl  = TextEditingController(text: existing?['key_passage'] ?? '');
    final themeCtrl       = TextEditingController(text: existing?['theme'] ?? '');
    final applicationCtrl = TextEditingController(text: existing?['application'] ?? '');
    final notesCtrl       = TextEditingController(text: existing?['notes'] ?? '');

    // Sermon points and prayer points as editable lists
    List<TextEditingController> sermonPoints = _parseList(existing?['sermon_points'])
        .map((s) => TextEditingController(text: s))
        .toList();
    List<TextEditingController> prayerPoints = _parseList(existing?['prayer_points'])
        .map((s) => TextEditingController(text: s))
        .toList();
    if (sermonPoints.isEmpty) sermonPoints.add(TextEditingController());
    if (prayerPoints.isEmpty) prayerPoints.add(TextEditingController());

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(existing == null ? 'New Sermon Note' : 'Edit Note',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(sermonTitleCtrl, 'Sermon Title', Icons.mic),
                  const SizedBox(height: 10),
                  _field(keyPassageCtrl, 'Key Passage (e.g. John 3:16)', Icons.menu_book),
                  const SizedBox(height: 10),
                  _field(themeCtrl, 'Theme', Icons.label_outline),
                  const SizedBox(height: 14),
                  _sectionLabel('Sermon Points'),
                  ...sermonPoints.asMap().entries.map((e) => _pointRow(
                        e.value,
                        onRemove: sermonPoints.length > 1
                            ? () => setS(() => sermonPoints.removeAt(e.key))
                            : null,
                      )),
                  _addButton('Add Point', () => setS(() => sermonPoints.add(TextEditingController()))),
                  const SizedBox(height: 14),
                  _sectionLabel('Application'),
                  const SizedBox(height: 6),
                  _field(applicationCtrl, 'How will I apply this?', Icons.lightbulb_outline, maxLines: 3),
                  const SizedBox(height: 14),
                  _sectionLabel('Notes'),
                  const SizedBox(height: 6),
                  _field(notesCtrl, 'General notes…', Icons.notes, maxLines: 4),
                  const SizedBox(height: 14),
                  _sectionLabel('Prayer Points'),
                  ...prayerPoints.asMap().entries.map((e) => _pointRow(
                        e.value,
                        onRemove: prayerPoints.length > 1
                            ? () => setS(() => prayerPoints.removeAt(e.key))
                            : null,
                      )),
                  _addButton('Add Prayer', () => setS(() => prayerPoints.add(TextEditingController()))),
                ],
              ),
            ),
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _supabase.client
                      .from('member_notes')
                      .delete()
                      .eq('id', existing['id']);
                  _load();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                final now = DateTime.now().toIso8601String();
                final payload = {
                  'user_id': _userId,
                  'sermon_title': sermonTitleCtrl.text.trim(),
                  'key_passage': keyPassageCtrl.text.trim(),
                  'theme': themeCtrl.text.trim(),
                  'application': applicationCtrl.text.trim(),
                  'notes': notesCtrl.text.trim(),
                  'sermon_points': sermonPoints
                      .map((c) => c.text.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                  'prayer_points': prayerPoints
                      .map((c) => c.text.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                  'updated_at': now,
                };
                if (existing == null) {
                  payload['created_at'] = now;
                  await _supabase.client.from('member_notes').insert(payload);
                } else {
                  await _supabase.client
                      .from('member_notes')
                      .update(payload)
                      .eq('id', existing['id']);
                }
                _load();
              },
              child: Text(existing == null ? 'Save' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.purple),
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _sectionLabel(String text) => Row(children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.purple)),
      ]);

  Widget _pointRow(TextEditingController ctrl, {VoidCallback? onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: 'Add point…',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
        ],
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Row(children: [
          const Icon(Icons.add_circle_outline,
              size: 16, color: AppColors.purple),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.purple)),
        ]),
      ),
    );
  }

  // ── card ─────────────────────────────────────────────────────────────────────

  Widget _buildCard(Map<String, dynamic> note) {
    final title    = note['sermon_title'] as String? ?? '';
    final passage  = note['key_passage']  as String? ?? '';
    final theme    = note['theme']        as String? ?? '';
    final notesText = note['notes']       as String? ?? '';
    final points   = _parseList(note['sermon_points']);
    final prayers  = _parseList(note['prayer_points']);
    final updatedAt = note['updated_at'] != null
        ? DateTime.tryParse(note['updated_at'])
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showNoteForm(note),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(children: [
                Expanded(
                  child: Text(
                    title.isNotEmpty ? title : 'Untitled',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                if (updatedAt != null)
                  Text(
                    '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ]),
              // Passage badge
              if (passage.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(passage,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.purple,
                          fontWeight: FontWeight.w600)),
                ),
              ],
              // Theme
              if (theme.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Theme: $theme',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
              // Notes preview
              if (notesText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(notesText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
              // Point counts
              if (points.isNotEmpty || prayers.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(children: [
                  if (points.isNotEmpty) ...[
                    const Icon(Icons.format_list_bulleted,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text('${points.length} point${points.length != 1 ? "s" : ""}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 12),
                  ],
                  if (prayers.isNotEmpty) ...[
                    const Icon(Icons.favorite_border,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                        '${prayers.length} prayer${prayers.length != 1 ? "s" : ""}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermon Notes'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Note',
            onPressed: () => _showNoteForm(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note_alt_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No sermon notes yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Take First Note'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: Colors.white),
                        onPressed: () => _showNoteForm(),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notes.length,
                    itemBuilder: (_, i) => _buildCard(_notes[i]),
                  ),
                ),
    );
  }
}
