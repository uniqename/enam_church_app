import 'package:flutter/material.dart';
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
            const SizedBox(height: 40),
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
