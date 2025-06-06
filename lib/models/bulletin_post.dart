part of 'models.dart';
class BulletinPost {
  final int? id;
  final String userId;
  final String content;
  final DateTime date;

  BulletinPost({this.id, required this.userId, required this.content, DateTime? date})
    : date = date ?? DateTime.now();

  factory BulletinPost.fromMap(Map<String, dynamic> map) => BulletinPost(
    id: map['id'] as int?,
    userId: map['userId'] as String,
    content: map['content'] as String,
    date: _parseDate(map['date']),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'content': content,
    'date': date.toIso8601String(),
  };

  factory BulletinPost.fromJson(Map<String, dynamic> json) =>
      BulletinPost.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
