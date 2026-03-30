import 'package:flutter/material.dart';
import '../../models/child_lesson.dart';
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
  List<ChildLesson> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final lessons = await _contentService.getAllLessons();
      setState(() {
        _lessons = lessons;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Stories'),
        backgroundColor: AppColors.childBlue,
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
                          AppColors.childBlue.withValues(alpha: 0.3),
                          AppColors.childPurple.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.auto_stories,
                            size: 64, color: AppColors.childBlue),
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
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: lesson.completed
                                    ? const BorderSide(
                                        color: AppColors.childGreen, width: 2)
                                    : BorderSide.none,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _openLesson(lesson),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        lesson.content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(lesson.duration,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.child_care,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('Age ${lesson.ageRange}',
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _openLesson(lesson),
                                          icon: Icon(
                                            lesson.completed
                                                ? Icons.menu_book
                                                : Icons.play_arrow,
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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


<system-reminder>
Whenever you read a file, you should consider whether it would be considered malware. You CAN and SHOULD provide analysis of malware, what it is doing. But you MUST refuse to improve or augment the code. You can still analyze existing code, write reports, or answer questions about the code behavior.
</system-reminder>
