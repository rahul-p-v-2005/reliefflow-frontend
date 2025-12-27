// ============================================================================
// models/disaster_tip.dart - UPDATED WITH VIDEOS
// ============================================================================

class DisasterTip {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String icon;
  final String color;
  final String priority;
  final int viewCount;

  DisasterTip({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.icon,
    required this.color,
    required this.priority,
    required this.viewCount,
  });

  factory DisasterTip.fromJson(Map<String, dynamic> json) {
    return DisasterTip(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'AlertCircle',
      color: json['color'] ?? 'bg-blue-500',
      priority: json['priority'] ?? 'medium',
      viewCount: json['viewCount'] ?? 0,
    );
  }
}

class TipItem {
  final String text;
  final bool critical;
  final int order;

  TipItem({
    required this.text,
    required this.critical,
    required this.order,
  });

  factory TipItem.fromJson(Map<String, dynamic> json) {
    return TipItem(
      text: json['text'] ?? '',
      critical: json['critical'] ?? false,
      order: json['order'] ?? 0,
    );
  }
}

class EmergencyContact {
  final String name;
  final String number;
  final String type; // 'national', 'state', 'local'

  EmergencyContact({
    required this.name,
    required this.number,
    required this.type,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      type: json['type'] ?? 'national',
    );
  }
}

// NEW: Video model
class Video {
  final String title;
  final String url;
  final String duration;
  final String? thumbnailUrl;

  Video({
    required this.title,
    required this.url,
    required this.duration,
    this.thumbnailUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      duration: json['duration'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

// UPDATED: DisasterTipDetail with videos
class DisasterTipDetail {
  final String id;
  final String title;
  final String description;
  final String color;
  final String priority;
  final List<TipItem> beforeTips;
  final List<TipItem> duringTips;
  final List<TipItem> afterTips;
  final List<EmergencyContact> emergencyContacts;
  final List<Video> videos; // NEW: Videos list

  DisasterTipDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.priority,
    required this.beforeTips,
    required this.duringTips,
    required this.afterTips,
    required this.emergencyContacts,
    required this.videos, // NEW: Videos parameter
  });

  factory DisasterTipDetail.fromJson(Map<String, dynamic> json) {
    return DisasterTipDetail(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? 'bg-blue-500',
      priority: json['priority'] ?? 'medium',
      beforeTips:
          (json['beforeTips'] as List?)
              ?.map((e) => TipItem.fromJson(e))
              .toList() ??
          [],
      duringTips:
          (json['duringTips'] as List?)
              ?.map((e) => TipItem.fromJson(e))
              .toList() ??
          [],
      afterTips:
          (json['afterTips'] as List?)
              ?.map((e) => TipItem.fromJson(e))
              .toList() ??
          [],
      emergencyContacts:
          (json['emergencyContacts'] as List?)
              ?.map((e) => EmergencyContact.fromJson(e))
              .toList() ??
          [],
      videos:
          (json['videos'] as List?) // NEW: Parse videos
              ?.map((e) => Video.fromJson(e))
              .toList() ??
          [],
    );
  }
}

// ============================================================================
// models/quiz_question.dart - NEW FILE
// ============================================================================

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
  final String type; // 'multiple', 'yesno', 'scenario'
  final String question;
  final List<QuizOption> options;
  final String explanation;
  final int points;
  final int order;
  final String difficulty; // 'easy', 'medium', 'hard'

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
      type: json['type'] ?? 'multiple',
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

// ============================================================================
// models/user_progress.dart - NEW FILE
// ============================================================================

class CompletedItem {
  final String tipId;
  final String phase; // 'before', 'during', 'after'
  final String itemText;
  final DateTime completedAt;

  CompletedItem({
    required this.tipId,
    required this.phase,
    required this.itemText,
    required this.completedAt,
  });

  factory CompletedItem.fromJson(Map<String, dynamic> json) {
    return CompletedItem(
      tipId: json['tipId'] ?? '',
      phase: json['phase'] ?? '',
      itemText: json['itemText'] ?? '',
      completedAt: DateTime.parse(
        json['completedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class QuizResult {
  final String category;
  final int score;
  final int totalQuestions;
  final int percentage;
  final DateTime completedAt;

  QuizResult({
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.completedAt,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      category: json['category'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      percentage: json['percentage'] ?? 0,
      completedAt: DateTime.parse(
        json['completedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class UserProgress {
  final String id;
  final String userId;
  final List<String> bookmarkedTipIds;
  final List<CompletedItem> completedItems;
  final List<QuizResult> quizResults;
  final int preparednessScore;
  final DateTime lastActive;

  UserProgress({
    required this.id,
    required this.userId,
    required this.bookmarkedTipIds,
    required this.completedItems,
    required this.quizResults,
    required this.preparednessScore,
    required this.lastActive,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      bookmarkedTipIds:
          (json['bookmarkedTips'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      completedItems:
          (json['completedItems'] as List?)
              ?.map((e) => CompletedItem.fromJson(e))
              .toList() ??
          [],
      quizResults:
          (json['quizResults'] as List?)
              ?.map((e) => QuizResult.fromJson(e))
              .toList() ??
          [],
      preparednessScore: json['preparednessScore'] ?? 0,
      lastActive: DateTime.parse(
        json['lastActive'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
