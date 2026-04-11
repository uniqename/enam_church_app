import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/colors.dart';

class QuizBuilderScreen extends StatefulWidget {
  final QuizModel? existing;
  final String? creatorId;
  final String? creatorName;

  const QuizBuilderScreen({
    super.key,
    this.existing,
    this.creatorId,
    this.creatorName,
  });

  @override
  State<QuizBuilderScreen> createState() => _QuizBuilderScreenState();
}

class _QuizBuilderScreenState extends State<QuizBuilderScreen> {
  final _quizService = QuizService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Bible';
  List<_EditableQuestion> _questions = [];
  bool _isSaving = false;

  static const _categories = ['Bible', 'Church', 'Children', 'General'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final q = widget.existing!;
      _titleController.text = q.title;
      _descController.text = q.description;
      _category = q.category;
      _questions = q.questions
          .map((qq) => _EditableQuestion.fromQuizQuestion(qq))
          .toList();
    }
    if (_questions.isEmpty) _addQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_EditableQuestion());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A quiz must have at least one question')),
      );
      return;
    }
    setState(() => _questions.removeAt(index));
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quiz title')),
      );
      return;
    }

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.questionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ${i + 1} text is required')),
        );
        return;
      }
      for (int j = 0; j < q.optionControllers.length; j++) {
        if (q.optionControllers[j].text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Question ${i + 1}: Option ${j + 1} is required')),
          );
          return;
        }
      }
    }

    setState(() => _isSaving = true);
    try {
      // Upload any pending question images
      for (final q in _questions) {
        if (q.imageFile != null) {
          final ext = q.imageFile!.path.split('.').last.toLowerCase();
          final path = 'quiz/${const Uuid().v4()}.$ext';
          final url = await SupabaseService().uploadImage(
              'church-media', path, q.imageFile!, contentType: 'image/jpeg');
          if (url != null) q.imageUrlController.text = url;
          q.imageFile = null;
        }
      }

      final questions = _questions
          .map((q) => QuizQuestion(
                question: q.questionController.text.trim(),
                imageUrl: q.imageUrlController.text.trim().isEmpty
                    ? null
                    : q.imageUrlController.text.trim(),
                options: q.optionControllers
                    .map((c) => c.text.trim())
                    .toList(),
                correctIndex: q.correctIndex,
                timeLimitSeconds: q.timeLimit,
              ))
          .toList();

      final isEdit = widget.existing != null;
      final quiz = QuizModel(
        id: isEdit ? widget.existing!.id : _quizService.generateId(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        createdBy: isEdit
            ? widget.existing!.createdBy
            : (widget.creatorId ?? 'unknown'),
        createdByName: isEdit
            ? widget.existing!.createdByName
            : (widget.creatorName ?? 'Admin'),
        createdAt: isEdit
            ? widget.existing!.createdAt
            : DateTime.now(),
        questions: questions,
      );

      if (isEdit) {
        await _quizService.updateQuiz(quiz);
      } else {
        await _quizService.saveQuiz(quiz);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Quiz updated!' : 'Quiz created!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Quiz' : 'Create Quiz'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Save',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.quiz, color: AppColors.purple),
              const SizedBox(width: 8),
              Text(
                'Questions (${_questions.length})',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._questions.asMap().entries.map((e) => _buildQuestionCard(e.key, e.value)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Question'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.purple,
              side: const BorderSide(color: AppColors.purple),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quiz Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: _inputDecor('Quiz Title', Icons.title),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: _inputDecor('Description (optional)', Icons.description),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: _inputDecor('Category', Icons.category),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Bible'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, _EditableQuestion q) {
    final answerColors = [
      const Color(0xFFE53935), // red
      const Color(0xFF1E88E5), // blue
      const Color(0xFFFDD835), // yellow
      const Color(0xFF43A047), // green
    ];
    final answerLabels = ['A', 'B', 'C', 'D'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.purple),
                  ),
                ),
                const Spacer(),
                // Time limit picker
                DropdownButton<int>(
                  value: q.timeLimit,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10s')),
                    DropdownMenuItem(value: 20, child: Text('20s')),
                    DropdownMenuItem(value: 30, child: Text('30s')),
                    DropdownMenuItem(value: 60, child: Text('60s')),
                  ],
                  onChanged: (v) =>
                      setState(() => q.timeLimit = v ?? 20),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () => _removeQuestion(index),
                  tooltip: 'Remove question',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: q.questionController,
              maxLines: 2,
              decoration: _inputDecor('Question text', Icons.help_outline),
            ),
            const SizedBox(height: 8),
            // Image picker row
            StatefulBuilder(builder: (_, setRow) => Row(
              children: [
                if (q.imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(q.imageFile!, width: 52, height: 52, fit: BoxFit.cover),
                  )
                else if (q.imageUrlController.text.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(q.imageUrlController.text, width: 52, height: 52, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 52, color: Colors.grey)),
                  )
                else
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.image_outlined, color: AppColors.purple),
                  ),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: const Text('Pick Image', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.purple, side: const BorderSide(color: AppColors.purple)),
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                    if (picked != null) {
                      setState(() => q.imageFile = File(picked.path));
                    }
                  },
                )),
                if (q.imageFile != null || q.imageUrlController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () => setState(() { q.imageFile = null; q.imageUrlController.text = ''; }),
                  ),
              ],
            )),
            const SizedBox(height: 12),
            const Text('Answers — tap the circle to mark correct:',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            ...List.generate(4, (i) {
              final isCorrect = q.correctIndex == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => q.correctIndex = i),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? answerColors[i]
                              : answerColors[i].withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: answerColors[i], width: 2),
                        ),
                        child: Center(
                          child: Text(
                            answerLabels[i],
                            style: TextStyle(
                              color: isCorrect
                                  ? Colors.white
                                  : answerColors[i],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: q.optionControllers[i],
                        decoration: InputDecoration(
                          hintText: 'Option ${i + 1}',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: answerColors[i], width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: isCorrect
                                    ? answerColors[i]
                                    : Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    if (isCorrect) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.purple, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

class _EditableQuestion {
  final TextEditingController questionController;
  final TextEditingController imageUrlController;
  final List<TextEditingController> optionControllers;
  int correctIndex;
  int timeLimit;
  File? imageFile; // pending local file before upload

  _EditableQuestion()
      : questionController = TextEditingController(),
        imageUrlController = TextEditingController(),
        optionControllers = List.generate(4, (_) => TextEditingController()),
        correctIndex = 0,
        timeLimit = 20;

  factory _EditableQuestion.fromQuizQuestion(QuizQuestion qq) {
    final e = _EditableQuestion();
    e.questionController.text = qq.question;
    e.imageUrlController.text = qq.imageUrl ?? '';
    for (int i = 0; i < qq.options.length && i < 4; i++) {
      e.optionControllers[i].text = qq.options[i];
    }
    e.correctIndex = qq.correctIndex;
    e.timeLimit = qq.timeLimitSeconds;
    return e;
  }
}
