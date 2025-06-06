part of 'models.dart';
@HiveType(typeId: 6)
class NotificationRecord {
  @HiveField(0)
  final String? title;
  @HiveField(1)
  final String? body;
  @HiveField(2)
  final DateTime timestamp;

  NotificationRecord({
    this.title,
    this.body,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NotificationRecord.fromMap(Map<String, dynamic> map) =>
      NotificationRecord(
        title: map['title'] as String?,
        body: map['body'] as String?,
        timestamp: _parseDate(map['timestamp']),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
      };

  factory NotificationRecord.fromJson(Map<String, dynamic> json) =>
      NotificationRecord.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory NotificationRecord.fromJsonString(String source) =>
      NotificationRecord.fromMap(jsonDecode(source));
}
