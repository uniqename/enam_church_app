import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/child_sermon.dart';
import '../../services/child_content_service.dart';
import '../../services/sermon_service.dart';
import '../../services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final childSermons = await _contentService.getAllSermons();
      final allSermons = await _sermonService.getAllSermons();
      final sharedSermons = allSermons
          .where((s) => s.audience == 'all' && s.fileUrl.isNotEmpty)
          .map((s) => ChildSermon(
                id: s.id, title: s.title, speaker: s.speaker,
                date: s.date, duration: '', views: 0, videoUrl: s.fileUrl,
              ))
          .toList();
      final childIds = childSermons.map((s) => s.id).toSet();
      final merged = [...childSermons, ...sharedSermons.where((s) => !childIds.contains(s.id))];
      final role = await _authService.getUserRole();
      setState(() {
        _sermons = merged;
        _canManage = role == 'admin' || role == 'pastor' || role == 'department_head' || role == 'media_team';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sermons: $e')),
        );
      }
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

  void _playSermon(ChildSermon sermon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(sermon.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.childOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_filled,
                      size: 64, color: AppColors.childOrange),
                  SizedBox(height: 8),
                  Text('Tap to Watch', style: TextStyle(color: AppColors.childOrange)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Speaker: ${sermon.speaker}'),
            Text('Duration: ${sermon.duration}'),
            Text('Views: ${sermon.views}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (sermon.videoUrl.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening sermon video...')),
                );
              }
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
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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
                                        child: const Icon(
                                          Icons.play_circle,
                                          size: 40,
                                          color: AppColors.childOrange,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sermon.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              sermon.speaker,
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.timer, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  sermon.duration,
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                                const SizedBox(width: 12),
                                                const Icon(Icons.visibility, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${sermon.views} views',
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
