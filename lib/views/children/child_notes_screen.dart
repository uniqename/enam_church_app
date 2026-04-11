import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';

class ChildNotesScreen extends StatefulWidget {
  const ChildNotesScreen({super.key});

  @override
  State<ChildNotesScreen> createState() => _ChildNotesScreenState();
}

class _ChildNotesScreenState extends State<ChildNotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _quotations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('child_notes') ?? '[]';
    final quotesJson = prefs.getString('child_quotations') ?? '[]';
    setState(() {
      _notes = List<Map<String, dynamic>>.from(jsonDecode(notesJson));
      _quotations = List<Map<String, dynamic>>.from(jsonDecode(quotesJson));
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_notes', jsonEncode(_notes));
  }

  Future<void> _saveQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_quotations', jsonEncode(_quotations));
  }

  void _addOrEditNote([Map<String, dynamic>? existing, int? index]) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final bodyCtrl = TextEditingController(text: existing?['body'] ?? '');

    showDialog(
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
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(
                  labelText: 'My notes', border: OutlineInputBorder()),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _notes.removeAt(index!));
                _saveNotes();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.childBlue,
                foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final entry = {
                'title': titleCtrl.text.trim(),
                'body': bodyCtrl.text.trim(),
                'date': DateTime.now().toIso8601String(),
              };
              setState(() {
                if (existing == null) {
                  _notes.insert(0, entry);
                } else {
                  _notes[index!] = entry;
                }
              });
              _saveNotes();
            },
            child: Text(existing == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _addOrEditQuotation([Map<String, dynamic>? existing, int? index]) {
    final verseCtrl = TextEditingController(text: existing?['verse'] ?? '');
    final refCtrl = TextEditingController(text: existing?['reference'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Save Bible Verse' : 'Edit Verse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: verseCtrl,
              decoration: const InputDecoration(
                  labelText: 'Verse text', border: OutlineInputBorder()),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: refCtrl,
              decoration: const InputDecoration(
                  labelText: 'Reference (e.g. John 3:16)',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _quotations.removeAt(index!));
                _saveQuotations();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.childGreen,
                foregroundColor: Colors.white),
            onPressed: () {
              if (verseCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final entry = {
                'verse': verseCtrl.text.trim(),
                'reference': refCtrl.text.trim(),
                'date': DateTime.now().toIso8601String(),
              };
              setState(() {
                if (existing == null) {
                  _quotations.insert(0, entry);
                } else {
                  _quotations[index!] = entry;
                }
              });
              _saveQuotations();
            },
            child: Text(existing == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes & Verses'),
        backgroundColor: AppColors.childPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.note_alt), text: 'My Notes'),
            Tab(icon: Icon(Icons.format_quote), text: 'Bible Verses'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.childPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          if (_tabController.index == 0) {
            _addOrEditNote();
          } else {
            _addOrEditQuotation();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesList(),
          _buildQuotationsList(),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: AppColors.childBlue.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('No notes yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Tap + to write your first note!',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notes.length,
      itemBuilder: (ctx, i) {
        final note = _notes[i];
        final date = DateTime.tryParse(note['date'] ?? '');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _addOrEditNote(note, i),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note_alt, size: 18, color: AppColors.childBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(note['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      if (date != null)
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                  if ((note['body'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      note['body'] as String,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuotationsList() {
    if (_quotations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_quote, size: 64, color: AppColors.childGreen.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('No saved verses yet',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Tap + to save your favourite Bible verse!',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quotations.length,
      itemBuilder: (ctx, i) {
        final q = _quotations[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _addOrEditQuotation(q, i),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.childGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.format_quote,
                            color: AppColors.childGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          (q['reference'] as String? ?? '').isNotEmpty
                              ? q['reference'] as String
                              : 'Bible Verse',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.childGreen,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q['verse'] as String? ?? '',
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
