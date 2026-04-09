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

  Future<void> _showDialog([Map<String, dynamic>? existing]) async {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final bodyCtrl = TextEditingController(text: existing?['body'] ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'New Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                  labelText: 'Note', border: OutlineInputBorder()),
            ),
          ],
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
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty &&
                  bodyCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final now = DateTime.now().toIso8601String();
              if (existing == null) {
                await _supabase.client.from('member_notes').insert({
                  'user_id': _userId,
                  'title': titleCtrl.text.trim(),
                  'body': bodyCtrl.text.trim(),
                  'created_at': now,
                  'updated_at': now,
                });
              } else {
                await _supabase.client
                    .from('member_notes')
                    .update({
                      'title': titleCtrl.text.trim(),
                      'body': bodyCtrl.text.trim(),
                      'updated_at': now,
                    })
                    .eq('id', existing['id']);
              }
              _load();
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Note',
            onPressed: () => _showDialog(),
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
                      const Text('No notes yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Write First Note'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: Colors.white),
                        onPressed: () => _showDialog(),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notes.length,
                    itemBuilder: (_, i) {
                      final note = _notes[i];
                      final updatedAt = note['updated_at'] != null
                          ? DateTime.tryParse(note['updated_at'])
                          : null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 10, 16, 10),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.note_alt,
                                color: AppColors.purple, size: 22),
                          ),
                          title: Text(
                            (note['title'] as String? ?? '').isNotEmpty
                                ? note['title']
                                : 'Untitled',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((note['body'] as String? ?? '').isNotEmpty)
                                Text(note['body'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12)),
                              if (updatedAt != null)
                                Text(
                                  '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                            ],
                          ),
                          onTap: () => _showDialog(note),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
