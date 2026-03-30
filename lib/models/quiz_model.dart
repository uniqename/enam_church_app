import 'dart:convert';

class QuizQuestion {
  final String question;
  final String? imageUrl;
  final List<String> options;
  final int correctIndex;
  final int timeLimitSeconds;

  const QuizQuestion({
    required this.question,
    this.imageUrl,
    required this.options,
    required this.correctIndex,
    this.timeLimitSeconds = 20,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      imageUrl: json['image_url'] as String?,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correct_index'] as int,
      timeLimitSeconds: json['time_limit_seconds'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'image_url': imageUrl,
        'options': options,
        'correct_index': correctIndex,
        'time_limit_seconds': timeLimitSeconds,
      };

  QuizQuestion copyWith({
    String? question,
    String? imageUrl,
    List<String>? options,
    int? correctIndex,
    int? timeLimitSeconds,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      imageUrl: imageUrl ?? this.imageUrl,
      options: options ?? List.from(this.options),
      correctIndex: correctIndex ?? this.correctIndex,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final List<QuizQuestion> questions;
  final bool isActive;

  const QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.questions,
    this.isActive = true,
  });

  int get questionCount => questions.length;
  bool get isSystem => createdBy == 'system';

  factory QuizModel.fromSupabase(Map<String, dynamic> json) {
    final questionsRaw = json['questions'];
    List<QuizQuestion> questions = [];
    if (questionsRaw is String) {
      final list = jsonDecode(questionsRaw) as List;
      questions = list
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    } else if (questionsRaw is List) {
      questions = questionsRaw
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    }
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      createdBy: json['created_by'] as String,
      createdByName: json['created_by_name'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      questions: questions,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'created_by': createdBy,
        'created_by_name': createdByName,
        'created_at': createdAt.toIso8601String(),
        'questions': jsonEncode(questions.map((q) => q.toJson()).toList()),
        'is_active': isActive,
      };
}
