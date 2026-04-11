import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/announcement.dart';
import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _announcementService = AnnouncementService();
  final _authService = AuthService();
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isDeptHead = false;
  String _userName = '';
  String _userDept = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userRole = await _authService.getUserRole();
      final userName = await _authService.getCurrentUserName();
      final userDept = await _authService.getUserDepartment();
      final announcements = await _announcementService.getAllAnnouncements();
      setState(() {
        _isAdmin = (userRole == 'admin' || userRole == 'pastor');
        _isDeptHead = userRole == 'departmentHead' || userRole == 'department_head';
        _userName = userName ?? '';
        _userDept = userDept ?? 'General';
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load announcements: $e')),
        );
      }
    }
  }

  bool get _canCreate => _isAdmin || _isDeptHead;

  // ── Upload helper ────────────────────────────────────────────────────────────
  Future<String?> _uploadMedia(File file, String mediaType) async {
    final ext = file.path.split('.').last.toLowerCase();
    final id = const Uuid().v4();
    final path = 'announcements/$id.$ext';
    final contentType = mediaType == 'image'
        ? 'image/jpeg'
        : mediaType == 'video'
            ? 'video/mp4'
            : 'audio/mpeg';
    return SupabaseService().uploadImage('church-media', path, file,
        contentType: contentType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? const Center(child: Text('No announcements yet'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _announcements.length,
                    itemBuilder: (context, index) =>
                        _buildCard(_announcements[index]),
                  ),
                ),
      floatingActionButton: _canCreate
          ? FloatingActionButton(
              onPressed: () => _showDialog(null),
              backgroundColor: AppColors.purple,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCard(Announcement a) {
    final borderColor = a.priority.toLowerCase() == 'high'
        ? Colors.red
        : a.priority.toLowerCase() == 'normal'
            ? Colors.orange
            : Colors.grey;
    final isImage = a.mediaUrl.isNotEmpty &&
        RegExp(r'\.(jpg|jpeg|png|gif|webp)(\?|$)', caseSensitive: false)
            .hasMatch(a.mediaUrl);
    final isAudio = a.mediaUrl.isNotEmpty &&
        RegExp(r'\.(mp3|m4a|aac|wav)(\?|$)', caseSensitive: false)
            .hasMatch(a.mediaUrl);
    final isVideo = a.mediaUrl.isNotEmpty &&
        RegExp(r'\.(mp4|mov|m4v)(\?|$)', caseSensitive: false)
            .hasMatch(a.mediaUrl);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 3),
      ),
      child: InkWell(
        onTap: _isAdmin ? () => _showDialog(a) : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image attachment ─────────────────────────────────────────
            if (isImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  a.mediaUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.campaign,
                          color: a.priority.toLowerCase() == 'high'
                              ? Colors.red
                              : Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(a.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      if (_isAdmin)
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: AppColors.purple),
                          onPressed: () => _showDialog(a),
                          tooltip: 'Edit',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(a.content),
                  // ── Audio / video badge ──────────────────────────────
                  if (isAudio || isVideo) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isVideo ? Icons.videocam : Icons.headphones,
                              size: 16, color: AppColors.purple),
                          const SizedBox(width: 6),
                          Text(
                            isVideo ? 'Video attached' : 'Audio attached',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.purple),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('By ${a.author}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      Text(DateFormat('MMM d, yyyy').format(a.date),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  if (a.department != 'General') ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(a.department,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.purple)),
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

  Future<void> _showDialog(Announcement? existing) async {
    final isEdit = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    final deptCtrl = TextEditingController(
        text: existing?.department ?? (_isDeptHead ? _userDept : 'General'));
    String priority = existing?.priority ?? 'Normal';
    String audience = existing?.audience ?? 'all';
    const validPriorities = ['Low', 'Normal', 'High'];
    if (!validPriorities.contains(priority)) priority = 'Normal';

    String mediaUrl = existing?.mediaUrl ?? '';
    File? pickedFile;
    String mediaType = ''; // 'image', 'audio', 'video'

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(isEdit ? 'Edit Announcement' : 'New Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Title *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Content', border: OutlineInputBorder()),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(
                      labelText: 'Priority', border: OutlineInputBorder()),
                  items: validPriorities
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setS(() => priority = v ?? 'Normal'),
                ),
                if (_isAdmin) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: deptCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Department', border: OutlineInputBorder()),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: audience,
                  decoration: const InputDecoration(
                      labelText: 'Audience',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people)),
                  items: const [
                    DropdownMenuItem(
                        value: 'all',
                        child: Text('Everyone (Adults + Kids)')),
                    DropdownMenuItem(
                        value: 'adults', child: Text('Adults Only')),
                  ],
                  onChanged: (v) => setS(() => audience = v ?? 'all'),
                ),
                const SizedBox(height: 16),
                // ── Media attachment ─────────────────────────────────────
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Attach media (optional)',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.image, size: 18),
                        label: const Text('Image', style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          if (picked != null) {
                            setS(() {
                              pickedFile = File(picked.path);
                              mediaType = 'image';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.attach_file, size: 18),
                        label: const Text('Audio/Video',
                            style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'mp3', 'm4a', 'aac', 'wav',
                              'mp4', 'mov', 'm4v'
                            ],
                          );
                          if (result?.files.single.path != null) {
                            final path = result!.files.single.path!;
                            final ext = path.split('.').last.toLowerCase();
                            setS(() {
                              pickedFile = File(path);
                              mediaType = ['mp4', 'mov', 'm4v'].contains(ext)
                                  ? 'video'
                                  : 'audio';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (pickedFile != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        mediaType == 'image'
                            ? Icons.image
                            : mediaType == 'video'
                                ? Icons.videocam
                                : Icons.headphones,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pickedFile!.path.split('/').last,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.success),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setS(() {
                          pickedFile = null;
                          mediaType = '';
                        }),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ] else if (mediaUrl.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text('Media already attached',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.success)),
                      ),
                      GestureDetector(
                        onTap: () => setS(() => mediaUrl = ''),
                        child: const Text('Remove',
                            style: TextStyle(
                                fontSize: 12, color: Colors.red)),
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
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmDelete(existing);
                },
                child: const Text('Delete',
                    style: TextStyle(color: Colors.red)),
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

                // Upload media if picked
                String finalMediaUrl = mediaUrl;
                if (pickedFile != null) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(const SnackBar(
                      content: Text('Uploading media…'),
                      duration: Duration(seconds: 30)));
                  final uploaded = await _uploadMedia(pickedFile!, mediaType);
                  messenger.hideCurrentSnackBar();
                  if (uploaded != null) {
                    finalMediaUrl = uploaded;
                  } else {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Media upload failed — saved without attachment'),
                        backgroundColor: Colors.orange));
                  }
                }

                final dept = deptCtrl.text.trim().isEmpty
                    ? (_isDeptHead ? _userDept : 'General')
                    : deptCtrl.text.trim();

                final messenger = ScaffoldMessenger.of(context);
                try {
                  if (isEdit) {
                    await _announcementService.updateAnnouncement(
                      existing.copyWith(
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        priority: priority,
                        department: dept,
                        audience: audience,
                        mediaUrl: finalMediaUrl,
                      ),
                    );
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Announcement updated'),
                        backgroundColor: AppColors.success));
                  } else {
                    await _announcementService.addAnnouncement(Announcement(
                      id: '',
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      priority: priority,
                      author: _userName,
                      date: DateTime.now(),
                      department: dept,
                      status: 'Active',
                      audience: audience,
                      mediaUrl: finalMediaUrl,
                    ));
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Announcement published'),
                        backgroundColor: AppColors.success));
                  }
                  _loadData();
                } catch (e) {
                  messenger.showSnackBar(
                      SnackBar(content: Text('Failed: $e')));
                }
              },
              child: Text(isEdit ? 'Save' : 'Publish'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Announcement a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text('Delete "${a.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _announcementService.deleteAnnouncement(a.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Announcement deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }
}
