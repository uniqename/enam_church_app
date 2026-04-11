import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/child_sermon.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/child_content_service.dart';
import '../../services/sermon_service.dart';
import '../../utils/colors.dart';

class ChildSermonsScreen extends StatefulWidget {
  const ChildSermonsScreen({super.key});

  @override
  State<ChildSermonsScreen> createState() => _ChildSermonsScreenState();
}

class _ChildSermonsScreenState extends State<ChildSermonsScreen> {
  final _contentService = ChildContentService();
  final _sermonService = SermonService();
  final _authService = AuthService();
  List<ChildSermon> _sermons = [];
  bool _isLoading = true;
  bool _canManage = false;

  // Built-in fallback videos — YouTube search URLs (always resolve)
  static final _builtInVideos = [
    ChildSermon(id: 'bi_1', title: 'The Creation Story for Kids', speaker: 'Kids Bible', date: DateTime(2024, 1, 1), duration: '5 min', views: 0, videoUrl: 'https://www.youtube.com/results?search_query=creation+story+for+kids+bible+animated'),
    ChildSermon(id: 'bi_2', title: "Noah's Ark for Children", speaker: 'Kids Bible', date: DateTime(2024, 1, 2), duration: '6 min', views: 0, videoUrl: 'https://www.youtube.com/results?search_query=noah+ark+bible+story+for+kids+animated'),
    ChildSermon(id: 'bi_3', title: 'David and Goliath', speaker: 'Kids Bible', date: DateTime(2024, 1, 3), duration: '7 min', views: 0, videoUrl: 'https://www.youtube.com/results?search_query=david+goliath+bible+story+for+children'),
    ChildSermon(id: 'bi_4', title: 'Jesus Loves Me - Animated', speaker: 'Kids Worship', date: DateTime(2024, 1, 4), duration: '3 min', views: 0, videoUrl: 'https://www.youtube.com/results?search_query=jesus+loves+me+bible+animated+kids+song'),
    ChildSermon(id: 'bi_5', title: 'The Prodigal Son', speaker: 'Kids Bible', date: DateTime(2024, 1, 5), duration: '5 min', views: 0, videoUrl: 'https://www.youtube.com/results?search_query=prodigal+son+bible+story+children+animated'),
  ];

  bool _isBuiltIn(ChildSermon s) => s.id.startsWith('bi_');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>([
        _contentService.getAllSermons(),
        _sermonService.getAllSermons(),
        _authService.getCurrentUserProfile(),
      ]);
      final childSermons = results[0] as List<ChildSermon>;
      final allSermons = results[1] as dynamic;
      final profile = results[2] as AppUser?;

      final sharedSermons = (allSermons as List)
          .where((s) => s.audience == 'all' && s.fileUrl.isNotEmpty)
          .map((s) => ChildSermon(
                id: s.id, title: s.title, speaker: s.speaker,
                date: s.date, duration: '', views: 0, videoUrl: s.fileUrl,
              ))
          .toList();
      final childIds = childSermons.map((s) => s.id).toSet();
      var merged = [...childSermons, ...sharedSermons.where((s) => !childIds.contains(s.id))];
      if (merged.isEmpty) merged = _builtInVideos;

      setState(() {
        _sermons = merged;
        _canManage = profile?.canManageChildrenContent ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _sermons = _builtInVideos;
        _isLoading = false;
      });
    }
  }

  Future<void> _openVideo(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _deleteSermon(ChildSermon sermon) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sermon?'),
        content: Text('Delete "${sermon.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _contentService.deleteSermon(sermon.id);
      _loadData();
    }
  }

  void _showSermonDialog(ChildSermon? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final speakerCtrl = TextEditingController(text: existing?.speaker ?? '');
    final urlCtrl = TextEditingController(text: existing?.videoUrl ?? '');
    final durationCtrl = TextEditingController(text: existing?.duration ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? "Add Children's Sermon" : "Edit Sermon"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: speakerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Speaker',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Video URL (YouTube link)',
                  hintText: 'https://youtube.com/...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: durationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g. 10 min)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.childOrange, foregroundColor: Colors.white),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final sermon = ChildSermon(
                id: existing?.id ?? '',
                title: titleCtrl.text.trim(),
                speaker: speakerCtrl.text.trim(),
                date: existing?.date ?? DateTime.now(),
                duration: durationCtrl.text.trim(),
                views: existing?.views ?? 0,
                videoUrl: urlCtrl.text.trim(),
              );
              if (existing == null) {
                await _contentService.addSermon(sermon);
              } else {
                await _contentService.updateSermon(sermon);
              }
              _loadData();
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _playSermon(ChildSermon sermon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(sermon.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _openVideo(sermon.videoUrl);
              },
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.childOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_filled, size: 64, color: AppColors.childOrange),
                    SizedBox(height: 8),
                    Text('Tap to Watch', style: TextStyle(color: AppColors.childOrange)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Speaker: ${sermon.speaker}'),
            if (sermon.duration.isNotEmpty) Text('Duration: ${sermon.duration}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openVideo(sermon.videoUrl);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.childOrange),
            child: const Text('Watch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Children's Sermons"),
        backgroundColor: AppColors.childOrange,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: _canManage
          ? FloatingActionButton(
              backgroundColor: AppColors.childOrange,
              foregroundColor: Colors.white,
              tooltip: 'Add Sermon',
              onPressed: () => _showSermonDialog(null),
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.childOrange.withValues(alpha: 0.3),
                          AppColors.childYellow.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.video_library, size: 64, color: AppColors.childOrange),
                        SizedBox(height: 16),
                        Text(
                          "Children's Sermons!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.childOrange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Watch fun sermons made just for you!',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sermons.isEmpty
                      ? const Center(child: Text('No sermons available yet'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _sermons.length,
                          itemBuilder: (context, index) {
                            final sermon = _sermons[index];
                            final canEdit = _canManage && !_isBuiltIn(sermon);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _playSermon(sermon),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: AppColors.childOrange.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.play_circle,
                                            size: 40, color: AppColors.childOrange),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sermon.title,
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(sermon.speaker,
                                                style: TextStyle(color: Colors.grey[600])),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.timer, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(sermon.duration,
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                const SizedBox(width: 12),
                                                const Icon(Icons.visibility, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text('${sermon.views} views',
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (canEdit)
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert,
                                              size: 20, color: Colors.grey),
                                          onSelected: (v) {
                                            if (v == 'edit') _showSermonDialog(sermon);
                                            if (v == 'delete') _deleteSermon(sermon);
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(value: 'edit', child: Row(
                                              children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')],
                                            )),
                                            PopupMenuItem(value: 'delete', child: Row(
                                              children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))],
                                            )),
                                          ],
                                        )
                                      else
                                        const Icon(Icons.chevron_right, color: AppColors.childOrange),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
