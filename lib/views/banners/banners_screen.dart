import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/banner_slide.dart';
import '../../services/banner_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final _service = BannerService();
  List<BannerSlideModel> _banners = [];
  bool _loading = true;
  String _audienceFilter = 'adult';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && ['adult', 'children', 'campaign'].contains(arg)) {
      _audienceFilter = arg;
    }
  }

  List<BannerSlideModel> get _filtered =>
      _banners.where((b) => b.audience == _audienceFilter).toList();

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _service.getAllBanners();
    setState(() { _banners = all; _loading = false; });
  }

  Future<String?> _uploadMedia(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    final path = 'banners/${const Uuid().v4()}.$ext';
    return await SupabaseService().uploadImage('church-media', path, file);
  }

  // Pick multiple images and create one banner per image
  Future<void> _pickAndSaveMultiple() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    // Ask audience once for all images
    String audience = _audienceFilter;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text('Uploading ${picked.length} image${picked.length > 1 ? 's' : ''}…'),
      duration: const Duration(seconds: 60),
    ));

    int uploaded = 0;
    for (int i = 0; i < picked.length; i++) {
      final file = File(picked[i].path);
      final filename = picked[i].name.replaceAll(RegExp(r'\.[^.]+$'), '');
      try {
        final url = await _uploadMedia(file);
        if (url != null) {
          await _service.addBanner(BannerSlideModel(
            id: '',
            title: filename,
            subtitle: '',
            mediaUrl: url,
            mediaType: 'image',
            linkRoute: '',
            isActive: true,
            sortOrder: _banners.length + i,
            audience: audience,
          ));
          uploaded++;
        }
      } catch (_) {}
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text('$uploaded of ${picked.length} banner${picked.length > 1 ? 's' : ''} added'),
      backgroundColor: uploaded > 0 ? AppColors.success : Colors.red,
      duration: const Duration(seconds: 4),
    ));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Banners'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Add Multiple Images',
            onPressed: _pickAndSaveMultiple,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Banner',
            onPressed: () => _showDialog(null),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Audience filter chips ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: Row(
                    children: [
                      _audienceChip('adult', 'Hero (Adult)', AppColors.purple),
                      const SizedBox(width: 8),
                      _audienceChip('children', "Children's", AppColors.childOrange),
                      const SizedBox(width: 8),
                      _audienceChip('campaign', 'Campaign', Colors.teal),
                    ],
                  ),
                ),
                // ── Banner list ──────────────────────────────────────────
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.view_carousel_outlined,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text('No ${_audienceLabel()} banners yet',
                                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Banner'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.purple,
                                    foregroundColor: Colors.white),
                                onPressed: () => _showDialog(null),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          onReorder: (oldIdx, newIdx) async {
                            if (newIdx > oldIdx) newIdx--;
                            final visible = _filtered.toList();
                            final item = visible.removeAt(oldIdx);
                            visible.insert(newIdx, item);
                            setState(() {
                              // Apply new order back to _banners
                              for (final b in visible) {
                                final idx = _banners.indexWhere((x) => x.id == b.id);
                                if (idx != -1) _banners[idx] = b;
                              }
                            });
                            for (int i = 0; i < visible.length; i++) {
                              await _service.updateBanner(visible[i].copyWith(sortOrder: i));
                            }
                          },
                          itemBuilder: (_, i) => _buildCard(_filtered[i], i),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _audienceChip(String value, String label, Color color) {
    final selected = _audienceFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _audienceFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade400),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : null,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _audienceLabel() {
    switch (_audienceFilter) {
      case 'children': return "Children's";
      case 'campaign': return 'Campaign';
      default: return 'Hero (Adult)';
    }
  }

  Widget _buildCard(BannerSlideModel b, int idx) {
    return Card(
      key: ValueKey(b.id),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        leading: _buildThumbnail(b),
        title: Text(b.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (b.subtitle.isNotEmpty)
              Text(b.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  b.mediaType == 'image'
                      ? Icons.image
                      : b.mediaType == 'video'
                          ? Icons.videocam
                          : b.mediaType == 'audio'
                              ? Icons.headphones
                              : Icons.text_fields,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(b.mediaType == 'none' ? 'Text only' : b.mediaType,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: b.isActive
                        ? AppColors.success.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    b.isActive ? 'Active' : 'Hidden',
                    style: TextStyle(
                      fontSize: 10,
                      color: b.isActive ? AppColors.success : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: b.audience == 'children'
                        ? AppColors.childOrange.withValues(alpha: 0.15)
                        : b.audience == 'campaign'
                            ? Colors.teal.withValues(alpha: 0.15)
                            : AppColors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    b.audience == 'children'
                        ? 'Kids'
                        : b.audience == 'campaign'
                            ? 'Campaign'
                            : 'Adult',
                    style: TextStyle(
                      fontSize: 10,
                      color: b.audience == 'children'
                          ? AppColors.childOrange
                          : b.audience == 'campaign'
                              ? Colors.teal
                              : AppColors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: b.isActive,
              activeThumbColor: AppColors.success,
              onChanged: (v) async {
                await _service.updateBanner(b.copyWith(isActive: v));
                _load();
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: AppColors.purple),
              onPressed: () => _showDialog(b),
            ),
            ReorderableDragStartListener(
              index: idx,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BannerSlideModel b) {
    if (b.mediaType == 'image' && b.mediaUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(b.mediaUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _iconBox(Icons.image)),
      );
    }
    if (b.mediaType == 'video') return _iconBox(Icons.videocam);
    if (b.mediaType == 'audio') return _iconBox(Icons.headphones);
    return _iconBox(Icons.campaign);
  }

  Widget _iconBox(IconData icon) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.purple, size: 28),
      );

  Future<void> _showDialog(BannerSlideModel? existing) async {
    final isEdit = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final subtitleCtrl = TextEditingController(text: existing?.subtitle ?? '');
    final routeCtrl = TextEditingController(text: existing?.linkRoute ?? '');
    bool isActive = existing?.isActive ?? true;
    String audience = existing?.audience ?? _audienceFilter;
    String mediaUrl = existing?.mediaUrl ?? '';
    String mediaType = existing?.mediaType ?? 'none';
    File? pickedFile;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(isEdit ? 'Edit Banner' : 'New Banner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Preview ────────────────────────────────────────────
                if (pickedFile != null && mediaType == 'image')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(pickedFile!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover),
                  )
                else if (mediaUrl.isNotEmpty && mediaType == 'image')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(mediaUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subtitleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Subtitle / Description',
                      border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: routeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Link (optional)',
                    hintText: '/sermons, /events, /giving…',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 14),
                // ── Media ──────────────────────────────────────────────
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Media',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.image, size: 18),
                        label: const Text('Image',
                            style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85);
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
                          final result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'mp3', 'm4a', 'aac', 'wav',
                              'mp4', 'mov', 'm4v'
                            ],
                          );
                          if (result?.files.single.path != null) {
                            final path = result!.files.single.path!;
                            final ext =
                                path.split('.').last.toLowerCase();
                            setS(() {
                              pickedFile = File(path);
                              mediaType =
                                  ['mp4', 'mov', 'm4v'].contains(ext)
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
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pickedFile!.path.split('/').last,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.success),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setS(() {
                          pickedFile = null;
                          mediaType = existing?.mediaType ?? 'none';
                          mediaUrl = existing?.mediaUrl ?? '';
                        }),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ] else if (mediaUrl.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('$mediaType media attached',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.success)),
                      ),
                      GestureDetector(
                        onTap: () => setS(() {
                          mediaUrl = '';
                          mediaType = 'none';
                        }),
                        child: const Text('Remove',
                            style: TextStyle(
                                fontSize: 11, color: Colors.red)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: audience,
                  decoration: const InputDecoration(
                    labelText: 'Show on',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'adult', child: Text('Adult Dashboard')),
                    DropdownMenuItem(value: 'children', child: Text("Children's Dashboard")),
                    DropdownMenuItem(value: 'campaign', child: Text('Campaign / Year Theme')),
                  ],
                  onChanged: (v) => setS(() => audience = v ?? 'adult'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Active (visible on dashboard)'),
                  value: isActive,
                  activeThumbColor: AppColors.success,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setS(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            if (isEdit)
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete Banner'),
                      content:
                          Text('Delete "${existing.title}"?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(c, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await _service.deleteBanner(existing.id);
                    _load();
                  }
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

                String finalUrl = mediaUrl;
                String finalType = mediaType;

                if (pickedFile != null) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(const SnackBar(
                      content: Text('Uploading media…'),
                      duration: Duration(seconds: 30)));
                  try {
                    final uploaded = await _uploadMedia(pickedFile!);
                    messenger.hideCurrentSnackBar();
                    if (uploaded != null) {
                      finalUrl = uploaded;
                      finalType = mediaType;
                    } else {
                      // isConfigured = false (demo mode)
                      finalUrl = '';
                      finalType = 'none';
                    }
                  } catch (e) {
                    messenger.hideCurrentSnackBar();
                    if (mounted) {
                      messenger.showSnackBar(SnackBar(
                        content: Text('Upload error: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 15),
                      ));
                    }
                    finalUrl = '';
                    finalType = 'none';
                  }
                }

                final entry = BannerSlideModel(
                  id: existing?.id ?? '',
                  title: titleCtrl.text.trim(),
                  subtitle: subtitleCtrl.text.trim(),
                  mediaUrl: finalUrl,
                  mediaType: finalType,
                  linkRoute: routeCtrl.text.trim(),
                  isActive: isActive,
                  sortOrder: existing?.sortOrder ?? _banners.length,
                  audience: audience,
                );

                if (isEdit) {
                  await _service.updateBanner(entry);
                } else {
                  await _service.addBanner(entry);
                }
                _load();
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
