part of 'models.dart';
class BulletinComment {
  final int? id;
  final int postId;
  final String userId;
  final String content;
  final DateTime date;

  BulletinComment({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory BulletinComment.fromMap(Map<String, dynamic> map) => BulletinComment(
    id: map['id'] as int?,
    postId: map['postId'] as int,
    userId: map['userId'] as String,
    content: map['content'] as String,
    date: _parseDate(map['date']),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'postId': postId,
    'userId': userId,
    'content': content,
    'date': date.toIso8601String(),
  };

  factory BulletinComment.fromJson(Map<String, dynamic> json) =>
      BulletinComment.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
