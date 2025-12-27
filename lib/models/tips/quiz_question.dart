class QuizOption {
  final String id;
  final String text;
  final bool correct;
  final int points;

  QuizOption({
    required this.id,
    required this.text,
    required this.correct,
    required this.points,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      correct: json['correct'] ?? false,
      points: json['points'] ?? 0,
    );
  }
}

class QuizQuestion {
  final String id;
  final String category;
  final String type;
  final String question;
  final List<QuizOption> options;
  final String explanation;
  final int points;
  final int order;
  final String difficulty;

  QuizQuestion({
    required this.id,
    required this.category,
    required this.type,
    required this.question,
    required this.options,
    required this.explanation,
    required this.points,
    required this.order,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      question: json['question'] ?? '',
      options:
          (json['options'] as List?)
              ?.map((e) => QuizOption.fromJson(e))
              .toList() ??
          [],
      explanation: json['explanation'] ?? '',
      points: json['points'] ?? 10,
      order: json['order'] ?? 0,
      difficulty: json['difficulty'] ?? 'medium',
    );
  }
}
