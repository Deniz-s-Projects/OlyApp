part of 'models.dart';

class WikiArticle {
  final int? id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;

  WikiArticle({
    this.id,
    required this.title,
    required this.content,
    required this.authorId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WikiArticle.fromMap(Map<String, dynamic> map) => WikiArticle(
        id: map['id'] as int?,
        title: map['title'] as String,
        content: map['content'] as String,
        authorId: map['authorId'] as String,
        createdAt: _parseDate(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'content': content,
        'authorId': authorId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WikiArticle.fromJson(Map<String, dynamic> json) =>
      WikiArticle.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
