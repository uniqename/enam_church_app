import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class ChurchLibraryScreen extends StatefulWidget {
  const ChurchLibraryScreen({super.key});

  @override
  State<ChurchLibraryScreen> createState() => _ChurchLibraryScreenState();
}

class _ChurchLibraryScreenState extends State<ChurchLibraryScreen> {
  final _auth = AuthService();
  final _supabase = SupabaseService();

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _canManage = false;
  String _filter = 'all';

  static const _categories = ['all', 'book', 'plan', 'pdf', 'audio', 'video', 'link'];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final role = await _auth.getUserRole();
    final isAdmin = role == 'admin' || role == 'pastor' ||
        role == 'dept_head' || role == 'media_team';
    try {
      final data = await _supabase.client
          .from('church_library')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(data as List);
          _canManage = isAdmin;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _items;
    return _items.where((i) => i['type'] == _filter).toList();
  }

  Future<void> _showAddDialog([Map<String, dynamic>? existing]) async {
    final isEdit = existing != null;
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final authorCtrl = TextEditingController(text: existing?['author'] ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final urlCtrl = TextEditingController(text: existing?['file_url'] ?? '');
    String type = existing?['type'] ?? 'book';
    File? pickedFile;
    String? fileExt;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(isEdit ? 'Edit Item' : 'Add to Library'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Title *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: authorCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Author / Speaker',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(
                      labelText: 'Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'book', child: Text('Book')),
                    DropdownMenuItem(value: 'plan', child: Text('Reading Plan')),
                    DropdownMenuItem(value: 'pdf', child: Text('PDF / Document')),
                    DropdownMenuItem(value: 'audio', child: Text('Audio')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                    DropdownMenuItem(value: 'link', child: Text('External Link')),
                  ],
                  onChanged: (v) => setS(() => type = v ?? 'book'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                // File upload OR URL
                if (type == 'link') ...[
                  TextField(
                    controller: urlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'URL *',
                      hintText: 'https://...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: Text(pickedFile != null
                              ? pickedFile!.path.split('/').last
                              : (existing?['file_url']?.isNotEmpty == true
                                  ? 'File attached'
                                  : 'Upload File'),
                              overflow: TextOverflow.ellipsis),
                          onPressed: () async {
                            FilePickerResult? result;
                            if (type == 'audio') {
                              result = await FilePicker.platform.pickFiles(
                                type: FileType.audio,
                              );
                            } else if (type == 'video') {
                              result = await FilePicker.platform.pickFiles(
                                type: FileType.video,
                              );
                            } else if (type == 'pdf' || type == 'plan') {
                              result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                              );
                            } else {
                              // book — image cover or PDF
                              final img = await ImagePicker().pickImage(
                                  source: ImageSource.gallery, imageQuality: 85);
                              if (img != null) {
                                setS(() {
                                  pickedFile = File(img.path);
                                  fileExt = img.path.split('.').last.toLowerCase();
                                });
                                return;
                              }
                            }
                            if (result?.files.single.path != null) {
                              setS(() {
                                pickedFile = File(result!.files.single.path!);
                                fileExt = result.files.single.extension?.toLowerCase();
                              });
                            }
                          },
                        ),
                      ),
                      if (pickedFile != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                          onPressed: () => setS(() => pickedFile = null),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (isEdit)
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _delete(existing['id'] as String);
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
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await _save(
                  id: existing?['id'] as String?,
                  title: titleCtrl.text.trim(),
                  author: authorCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  type: type,
                  file: pickedFile,
                  fileExt: fileExt,
                  existingUrl: type == 'link' ? urlCtrl.text.trim() : (existing?['file_url'] ?? ''),
                );
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save({
    String? id,
    required String title,
    required String author,
    required String description,
    required String type,
    File? file,
    String? fileExt,
    required String existingUrl,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    String fileUrl = existingUrl;

    if (file != null) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Uploading…'), duration: Duration(seconds: 30)));
      final path = 'library/${const Uuid().v4()}.$fileExt';
      try {
        final uploaded = await _supabase.uploadImage('church-media', path, file);
        messenger.hideCurrentSnackBar();
        if (uploaded == null) return;
        fileUrl = uploaded;
      } catch (e) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10)));
        return;
      }
    }

    try {
      final data = {
        'title': title,
        'author': author,
        'description': description,
        'type': type,
        'file_url': fileUrl,
      };
      if (id == null) {
        await _supabase.client.from('church_library').insert(data);
      } else {
        await _supabase.client.from('church_library').update(data).eq('id', id);
      }
      _loadAll();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _supabase.client.from('church_library').delete().eq('id', id);
      _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    final url = item['file_url'] as String? ?? '';
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open this item')));
      }
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'plan': return Icons.checklist;
      case 'audio': return Icons.headphones;
      case 'video': return Icons.play_circle;
      case 'link': return Icons.open_in_new;
      default: return Icons.menu_book;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'pdf': return Colors.red;
      case 'plan': return AppColors.accentTeal;
      case 'audio': return AppColors.purple;
      case 'video': return AppColors.error;
      case 'link': return AppColors.accentBlue;
      default: return AppColors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church Library'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_canManage)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Item',
              onPressed: () => _showAddDialog(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected
                              ? AppColors.purple
                              : Colors.grey.shade400),
                    ),
                    child: Text(
                      cat == 'all' ? 'All' : cat[0].toUpperCase() + cat.substring(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : null,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.library_books_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _canManage
                                  ? 'No items yet. Tap + to add books,\nplans, PDFs, audio and more.'
                                  : 'No library items yet.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                            if (_canManage) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showAddDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Item'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.purple,
                                    foregroundColor: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAll,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _buildCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final type = item['type'] as String? ?? 'book';
    final title = item['title'] as String? ?? '';
    final author = item['author'] as String? ?? '';
    final description = item['description'] as String? ?? '';
    final hasFile = (item['file_url'] as String? ?? '').isNotEmpty;
    final color = _colorFor(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: hasFile ? () => _open(item) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(type), color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(type,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    if (author.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(author,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500])),
                    ],
                    if (hasFile) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.open_in_new,
                              size: 12, color: color),
                          const SizedBox(width: 4),
                          Text('Tap to open',
                              style: TextStyle(
                                  fontSize: 11, color: color)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (_canManage)
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: () => _showAddDialog(item),
                  tooltip: 'Edit',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
