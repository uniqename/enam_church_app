import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/video_content.dart';
import '../../services/video_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class AdminVideoUploadScreen extends StatefulWidget {
  const AdminVideoUploadScreen({super.key});

  @override
  State<AdminVideoUploadScreen> createState() => _AdminVideoUploadScreenState();
}

class _AdminVideoUploadScreenState extends State<AdminVideoUploadScreen>
    with SingleTickerProviderStateMixin {
  final _videoService = VideoService();
  final _authService = AuthService();

  late TabController _tabController;

  List<VideoContent> _adultVideos = [];
  List<VideoContent> _childrenVideos = [];
  bool _isLoading = true;
  String? _currentUserName;

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
    setState(() => _isLoading = true);
    try {
      final name = await _authService.getCurrentUserName();
      final all = await _videoService.getAllVideos();
      setState(() {
        _currentUserName = name ?? 'Admin';
        _adultVideos =
            all.where((v) => v.audience == 'adults' || v.audience == 'all').toList();
        _childrenVideos =
            all.where((v) => v.audience == 'children' || v.audience == 'all').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load videos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Management'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Adult Content'),
            Tab(icon: Icon(Icons.child_care), text: "Children's Content"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSection(audience: 'adults', videos: _adultVideos),
                _buildSection(audience: 'children', videos: _childrenVideos),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String audience,
    required List<VideoContent> videos,
  }) {
    final isAdult = audience == 'adults';
    final accentColor = isAdult ? AppColors.purple : AppColors.childGreen;
    final categories = isAdult
        ? ['sermon', 'worship', 'teaching', 'devotional']
        : ['children-sermon', 'children-lesson'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadForm(
            audience: audience,
            accentColor: accentColor,
            categories: categories,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.video_library, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Uploaded Videos (${videos.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          videos.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      'No videos uploaded yet.\nUse the form above to add videos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: videos.length,
                  itemBuilder: (context, index) =>
                      _buildVideoTile(videos[index], accentColor),
                ),
        ],
      ),
    );
  }

  Widget _buildUploadForm({
    required String audience,
    required Color accentColor,
    required List<String> categories,
  }) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = categories.first;
    String selectedAudience = audience;
    bool isSubmitting = false;

    return StatefulBuilder(
      builder: (context, setFormState) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  'Add New Video',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Video Title',
                prefixIcon: Icon(Icons.title, color: accentColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'Video / Audio URL',
                hintText: 'YouTube, direct .mp4, .mp3, or any stream URL',
                helperText: 'YouTube links, .mp4 videos, .mp3 audio, Vimeo, etc.',
                prefixIcon: Icon(Icons.link, color: accentColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description, color: accentColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(_formatCategory(c),
                                style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) =>
                        setFormState(() => selectedCategory = v ?? categories.first),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedAudience,
                    decoration: InputDecoration(
                      labelText: 'Target',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'adults', child: Text('Adults')),
                      DropdownMenuItem(
                          value: 'children', child: Text('Children')),
                      DropdownMenuItem(value: 'all', child: Text('Everyone')),
                    ],
                    onChanged: (v) =>
                        setFormState(() => selectedAudience = v ?? audience),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        final url = urlController.text.trim();
                        final desc = descController.text.trim();

                        if (title.isEmpty || url.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Title and URL are required')),
                          );
                          return;
                        }

                        if (!_isValidUrl(url)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid URL (YouTube, mp4, mp3, etc.)'),
                            ),
                          );
                          return;
                        }

                        setFormState(() => isSubmitting = true);
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await _videoService.addVideo(VideoContent(
                            id: '',
                            title: title,
                            youtubeUrl: url,
                            description: desc,
                            audience: selectedAudience,
                            category: selectedCategory,
                            uploadedAt: DateTime.now(),
                            uploadedBy: _currentUserName ?? 'Admin',
                          ));
                          titleController.clear();
                          urlController.clear();
                          descController.clear();
                          await _loadData();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Video added successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Failed to add video: $e')),
                          );
                        } finally {
                          setFormState(() => isSubmitting = false);
                        }
                      },
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(isSubmitting ? 'Uploading...' : 'Add Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTile(VideoContent video, Color accentColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.play_circle_fill, color: accentColor, size: 28),
        ),
        title: Text(
          video.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              _formatCategory(video.category),
              style: TextStyle(
                  fontSize: 11,
                  color: accentColor,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              'Uploaded ${DateFormat('MMM d, y').format(video.uploadedAt)} · ${video.uploadedBy}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(video),
          tooltip: 'Delete video',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(VideoContent video) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Video?'),
        content: Text('Remove "${video.title}" from the video library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _videoService.deleteVideo(video.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'children-sermon':
        return 'Children Sermon';
      case 'children-lesson':
        return 'Children Lesson';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}
