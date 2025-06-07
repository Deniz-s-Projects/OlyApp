part of 'models.dart';

class Suggestion {
  final String? id;
  final String userId;
  final String content;
  final DateTime createdAt;

  Suggestion({
    this.id,
    required this.userId,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Suggestion.fromMap(Map<String, dynamic> map) => Suggestion(
    id: map['id']?.toString(),
    userId: map['userId'] as String,
    content: map['content'] as String,
    createdAt: _parseDate(map['createdAt']),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Suggestion.fromJson(Map<String, dynamic> json) =>
      Suggestion.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
