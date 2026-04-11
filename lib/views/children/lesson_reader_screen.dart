import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/child_lesson.dart';
import '../../services/child_content_service.dart';
import '../../utils/colors.dart';

class LessonReaderScreen extends StatefulWidget {
  final ChildLesson lesson;

  const LessonReaderScreen({super.key, required this.lesson});

  @override
  State<LessonReaderScreen> createState() => _LessonReaderScreenState();
}

class _LessonReaderScreenState extends State<LessonReaderScreen> {
  final _contentService = ChildContentService();
  bool _completed = false;
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _completed = widget.lesson.completed;
  }

  Future<void> _markComplete() async {
    try {
      setState(() => _completed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Great job! Lesson completed! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: AppColors.childBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(12.0, 30.0)),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(12.0, 30.0)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.childBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.childBlue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.childBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.lesson.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.childBlue,
                          ),
                        ),
                      ),
                      if (_completed)
                        const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(widget.lesson.duration, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.child_care, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Ages ${widget.lesson.ageRange}',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Lesson content
            Text(
              widget.lesson.content.isEmpty
                  ? 'Lesson content will appear here. Ask your teacher or parent to read it with you!'
                  : widget.lesson.content,
              style: TextStyle(fontSize: _fontSize, height: 1.6),
            ),
            const SizedBox(height: 28),
            // ── Bible passage section ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.childBlue.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.childBlue.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.childBlue, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        widget.lesson.scriptureRef.isNotEmpty
                            ? 'Bible Passage: ${widget.lesson.scriptureRef}'
                            : 'Read & Hear God\'s Word',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.childBlue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 1: Read in NIV + Listen (audio)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.menu_book, size: 16),
                          label: Text(
                            widget.lesson.scriptureRef.isNotEmpty
                                ? widget.lesson.scriptureRef
                                : 'Read in Bible',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            final q = widget.lesson.scriptureRef.isNotEmpty
                                ? widget.lesson.scriptureRef
                                : widget.lesson.title;
                            final encoded = Uri.encodeComponent(q);
                            launchUrl(
                              Uri.parse('https://www.bible.com/search/bible?q=$encoded'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.childBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.headphones, size: 16),
                          label: const Text('Listen / Audio',
                              style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            final q = widget.lesson.scriptureRef.isNotEmpty
                                ? widget.lesson.scriptureRef
                                : widget.lesson.title;
                            final encoded = Uri.encodeComponent(q);
                            launchUrl(
                              Uri.parse('https://www.bible.com/search/bible?q=$encoded'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.childPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row 2: Children's Bible (ICB — simpler language for kids)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.child_care, size: 16,
                          color: AppColors.childOrange),
                      label: Text(
                        widget.lesson.scriptureRef.isNotEmpty
                            ? 'Children\'s Bible (ICB) — ${widget.lesson.scriptureRef}'
                            : 'Open in Children\'s Bible (ICB)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.childOrange),
                      ),
                      onPressed: () {
                        final q = widget.lesson.scriptureRef.isNotEmpty
                            ? widget.lesson.scriptureRef
                            : widget.lesson.title;
                        final encoded = Uri.encodeComponent(q);
                        // version_id=1588 = International Children's Bible (ICB)
                        launchUrl(
                          Uri.parse(
                              'https://www.bible.com/search/bible?q=$encoded&version_id=1588'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.childOrange),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Complete button
            if (!_completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _markComplete,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('I Finished This Lesson!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.childGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Lesson Completed! Great Job! 🎉',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
