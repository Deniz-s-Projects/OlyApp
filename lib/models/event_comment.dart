part of 'models.dart';
class EventComment {
  final String? id;
  final int eventId;
  final String content;
  final DateTime date;

  EventComment({
    this.id,
    required this.eventId,
    required this.content,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory EventComment.fromMap(Map<String, dynamic> map) => EventComment(
        id: map['id'] as String?,
        eventId: map['eventId'] is int
            ? map['eventId'] as int
            : int.parse(map['eventId'].toString()),
        content: map['content'] as String,
        date: _parseDate(map['date']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'eventId': eventId,
        'content': content,
        'date': date.toIso8601String(),
      };

  factory EventComment.fromJson(Map<String, dynamic> json) =>
      EventComment.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
