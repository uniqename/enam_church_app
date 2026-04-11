import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/event_photo.dart';
import '../../services/event_photo_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class EventGalleryScreen extends StatefulWidget {
  const EventGalleryScreen({super.key});

  @override
  State<EventGalleryScreen> createState() => _EventGalleryScreenState();
}

class _EventGalleryScreenState extends State<EventGalleryScreen> {
  final _photoService = EventPhotoService();
  final _authService = AuthService();

  List<EventPhoto> _photos = [];
  List<String> _departments = ['Church'];
  String _selectedDept = 'Church';
  bool _isLoading = true;
  bool _canUpload = false;
  String? _userRole;
  String? _userName;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    _userRole = await _authService.getUserRole();
    _userName = await _authService.getCurrentUserName();
    _userId = await _authService.getCurrentUserId();

    // Media team, admin, pastor, department heads can upload
    _canUpload = ['admin', 'pastor', 'departmentHead', 'department_head']
        .contains(_userRole);

    final photos = await _photoService.getAllPhotos();
    final depts = await _photoService.getDepartments();
    final allDepts = ['Church', ...depts.where((d) => d != 'Church')];

    setState(() {
      _photos = photos;
      _departments = allDepts.toSet().toList();
      _isLoading = false;
    });
  }

  List<EventPhoto> get _filteredPhotos {
    if (_selectedDept == 'Church') return _photos;
    return _photos
        .where((p) =>
            p.department == _selectedDept || p.department == 'Church')
        .toList();
  }

  Future<void> _uploadPhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    // Show upload form
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final eventCtrl = TextEditingController();
    String dept = _selectedDept == 'Church' ? 'Church' : _selectedDept;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Upload Event Photo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(picked.path),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Photo Title *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter a title'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: eventCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Event Name (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: dept,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    items: _departments
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setDlgState(() => dept = v ?? 'Church'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                await _doUpload(
                  file: File(picked.path),
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  eventName: eventCtrl.text.trim().isEmpty
                      ? null
                      : eventCtrl.text.trim(),
                  department: dept,
                );
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doUpload({
    required File file,
    required String title,
    String? description,
    String? eventName,
    required String department,
  }) async {
    try {
      await _photoService.uploadPhoto(
        imageFile: file,
        title: title,
        description: description,
        uploadedBy: _userId ?? '',
        uploaderName: _userName ?? 'Admin',
        department: department,
        eventName: eventName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto(EventPhoto photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Photo'),
        content: Text('Delete "${photo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _photoService.deletePhoto(photo.id, photo.imageUrl);
        _loadAll();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Gallery'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_canUpload)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _uploadPhoto,
              tooltip: 'Upload Photo',
            ),
        ],
      ),
      floatingActionButton: _canUpload
          ? FloatingActionButton.extended(
              onPressed: _uploadPhoto,
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Upload'),
            )
          : null,
      body: Column(
        children: [
          // Department filter
          if (_departments.length > 1)
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: _departments.length,
                itemBuilder: (_, i) {
                  final dept = _departments[i];
                  final selected = dept == _selectedDept;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDept = dept),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.purple
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.purple
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        dept,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPhotos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo_library_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No photos yet',
                                style: TextStyle(color: Colors.grey)),
                            if (_canUpload) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _uploadPhoto,
                                icon: const Icon(Icons.add),
                                label: const Text('Upload First Photo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _filteredPhotos.length,
                        itemBuilder: (_, i) {
                          final photo = _filteredPhotos[i];
                          return _PhotoCard(
                            photo: photo,
                            canDelete: _canUpload,
                            onDelete: () => _deletePhoto(photo),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final EventPhoto photo;
  final bool canDelete;
  final VoidCallback onDelete;

  const _PhotoCard({
    required this.photo,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullPhoto(context),
      child: Card(
        elevation: 3,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: photo.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                  if (canDelete)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  if (photo.department != 'Church')
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          photo.department,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (photo.eventName != null)
                    Text(
                      photo.eventName!,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullPhoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullPhotoScreen(photo: photo),
      ),
    );
  }
}

class _FullPhotoScreen extends StatelessWidget {
  final EventPhoto photo;
  const _FullPhotoScreen({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(photo.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: photo.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.image_not_supported,
                          color: Colors.white, size: 64),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                if (photo.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    photo.description!,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white54, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      photo.uploaderName,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.group, color: Colors.white54, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      photo.department,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
