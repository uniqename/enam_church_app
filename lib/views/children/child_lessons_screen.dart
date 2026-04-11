import 'package:flutter/material.dart';
import '../../models/child_lesson.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/child_content_service.dart';
import '../../utils/colors.dart';
import 'lesson_reader_screen.dart';

class ChildLessonsScreen extends StatefulWidget {
  const ChildLessonsScreen({super.key});

  @override
  State<ChildLessonsScreen> createState() => _ChildLessonsScreenState();
}

class _ChildLessonsScreenState extends State<ChildLessonsScreen> {
  final _contentService = ChildContentService();
  final _auth = AuthService();
  List<ChildLesson> _lessons = [];
  AppUser? _userProfile;
  bool _isLoading = true;

  bool get _canManage => _userProfile?.canManageChildrenContent ?? false;

  // Stub IDs from local_data_service are short ('ls-1' etc); DB UUIDs are long
  bool _isDbLesson(ChildLesson l) => l.id.length > 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>([
        _contentService.getAllLessons(),
        _auth.getCurrentUserProfile(),
      ]);
      setState(() {
        _lessons = results[0] as List<ChildLesson>;
        _userProfile = results[1] as AppUser?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load lessons: $e')),
        );
      }
    }
  }

  void _openLesson(ChildLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonReaderScreen(lesson: lesson)),
    ).then((_) => _loadData());
  }

  Future<void> _deleteLesson(ChildLesson lesson) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Story?'),
        content: Text('Delete "${lesson.title}"? This cannot be undone.'),
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
      await _contentService.deleteLesson(lesson.id);
      _loadData();
    }
  }

  void _showLessonDialog(ChildLesson? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    final scriptureCtrl = TextEditingController(text: existing?.scriptureRef ?? '');
    final durationCtrl = TextEditingController(text: existing?.duration ?? '15 min');
    final ageCtrl = TextEditingController(text: existing?.ageRange ?? '5-10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Bible Story' : 'Edit Bible Story'),
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
                controller: contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Story Content',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: scriptureCtrl,
                decoration: const InputDecoration(
                  labelText: 'Scripture Reference (e.g. John 3:16)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: durationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        hintText: '15 min',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: ageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Age Range',
                        hintText: '5-10',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.childBlue, foregroundColor: Colors.white),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final lesson = ChildLesson(
                id: existing?.id ?? '',
                title: titleCtrl.text.trim(),
                content: contentCtrl.text.trim(),
                duration: durationCtrl.text.trim().isEmpty ? '15 min' : durationCtrl.text.trim(),
                ageRange: ageCtrl.text.trim().isEmpty ? '5-10' : ageCtrl.text.trim(),
                completed: existing?.completed ?? false,
                scriptureRef: scriptureCtrl.text.trim(),
              );
              if (existing == null) {
                await _contentService.addLesson(lesson);
              } else {
                await _contentService.updateLesson(lesson);
              }
              _loadData();
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
        title: const Text('Bible Stories'),
        backgroundColor: AppColors.childBlue,
        foregroundColor: Colors.white,
        actions: [
          if (_canManage)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Story',
              onPressed: () => _showLessonDialog(null),
            ),
        ],
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
                          AppColors.childBlue.withValues(alpha: 0.3),
                          AppColors.childPurple.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.auto_stories, size: 64, color: AppColors.childBlue),
                        SizedBox(height: 16),
                        Text(
                          'Amazing Bible Stories!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.childBlue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Discover God's love through wonderful stories!",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _lessons.isEmpty
                      ? const Center(child: Text('No lessons available yet'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _lessons.length,
                          itemBuilder: (context, index) {
                            final lesson = _lessons[index];
                            final canEdit = _canManage && _isDbLesson(lesson);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: lesson.completed
                                    ? const BorderSide(color: AppColors.childGreen, width: 2)
                                    : BorderSide.none,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _openLesson(lesson),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lesson.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (lesson.completed)
                                            const Icon(Icons.check_circle,
                                                color: AppColors.childGreen),
                                          if (canEdit)
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert,
                                                  size: 20, color: Colors.grey),
                                              onSelected: (v) {
                                                if (v == 'edit') _showLessonDialog(lesson);
                                                if (v == 'delete') _deleteLesson(lesson);
                                              },
                                              itemBuilder: (_) => const [
                                                PopupMenuItem(value: 'edit', child: Row(
                                                  children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')],
                                                )),
                                                PopupMenuItem(value: 'delete', child: Row(
                                                  children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))],
                                                )),
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        lesson.content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(lesson.duration,
                                              style: const TextStyle(fontSize: 12)),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.child_care, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('Age ${lesson.ageRange}',
                                              style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _openLesson(lesson),
                                          icon: Icon(
                                            lesson.completed ? Icons.menu_book : Icons.play_arrow,
                                            size: 18,
                                          ),
                                          label: Text(lesson.completed
                                              ? 'Read Again!'
                                              : 'Read Story!'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: lesson.completed
                                                ? AppColors.childGreen
                                                : AppColors.childBlue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
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
