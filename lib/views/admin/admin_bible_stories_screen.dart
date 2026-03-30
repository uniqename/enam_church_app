import 'package:flutter/material.dart';
import '../../models/child_lesson.dart';
import '../../services/child_content_service.dart';
import '../../utils/colors.dart';

class AdminBibleStoriesScreen extends StatefulWidget {
  const AdminBibleStoriesScreen({super.key});

  @override
  State<AdminBibleStoriesScreen> createState() =>
      _AdminBibleStoriesScreenState();
}

class _AdminBibleStoriesScreenState extends State<AdminBibleStoriesScreen> {
  final _contentService = ChildContentService();
  List<ChildLesson> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    final lessons = await _contentService.getAllLessons();
    setState(() {
      _lessons = lessons;
      _isLoading = false;
    });
  }

  Future<void> _showAddEditDialog([ChildLesson? existing]) async {
    final titleCtrl =
        TextEditingController(text: existing?.title ?? '');
    final contentCtrl =
        TextEditingController(text: existing?.content ?? '');
    final durationCtrl =
        TextEditingController(text: existing?.duration ?? '5 min');
    final ageCtrl =
        TextEditingController(text: existing?.ageRange ?? '5-10');
    final formKey = GlobalKey<FormState>();
    final isEdit = existing != null;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Bible Story' : 'Add Bible Story'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Story Title *',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Story Content *',
                    prefixIcon: Icon(Icons.article),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter story content' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: durationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                          prefixIcon: Icon(Icons.timer),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: ageCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Age Range',
                          prefixIcon: Icon(Icons.child_care),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
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
              backgroundColor: AppColors.childBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);

              try {
                final lesson = ChildLesson(
                  id: existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  duration: durationCtrl.text.trim().isEmpty
                      ? '5 min'
                      : durationCtrl.text.trim(),
                  ageRange: ageCtrl.text.trim().isEmpty
                      ? '5-10'
                      : ageCtrl.text.trim(),
                  completed: existing?.completed ?? false,
                );
                await _contentService.updateLesson(lesson);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit
                          ? 'Story updated!'
                          : 'Story added successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
                _loadLessons();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Add Story'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bible Stories'),
        backgroundColor: AppColors.childBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Add Story',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.childBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Story'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.childBlue.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.childBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${_lessons.length} stories available for children',
                        style: const TextStyle(
                            color: AppColors.childBlue, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _lessons.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_stories,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'No stories yet.\nTap + to add the first one!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showAddEditDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Story'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.childBlue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _lessons.length,
                          itemBuilder: (_, i) {
                            final lesson = _lessons[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.childBlue
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.auto_stories,
                                      color: AppColors.childBlue),
                                ),
                                title: Text(
                                  lesson.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${lesson.ageRange} yrs • ${lesson.duration}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _showAddEditDialog(lesson);
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Delete Story'),
                                          content: Text(
                                              'Delete "${lesson.title}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        // Mark as deleted via empty content
                                        try {
                                          await _contentService.updateLesson(
                                            ChildLesson(
                                              id: lesson.id,
                                              title: lesson.title,
                                              content: '',
                                              duration: lesson.duration,
                                              ageRange: lesson.ageRange,
                                              completed: false,
                                            ),
                                          );
                                          _loadLessons();
                                        } catch (_) {}
                                      }
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit,
                                              size: 18,
                                              color: AppColors.childBlue),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
