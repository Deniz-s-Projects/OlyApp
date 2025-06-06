part of 'models.dart';
@HiveType(typeId: 2)
class Message {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int requestId;
  @HiveField(2)
  final String senderId;
  @HiveField(3)
  final String content;
  @HiveField(4)
  final DateTime timestamp;

  Message({
    this.id,
    required this.requestId,
    required this.senderId,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Message.fromMap(Map<String, dynamic> map) => Message(
    id: map['id'] as int?,
    requestId: map['requestId'] as int,
    senderId: map['senderId'] as String,
    content: map['content'] as String,
    timestamp: _parseDate(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'requestId': requestId,
    'senderId': senderId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory Message.fromJsonString(String source) =>
      Message.fromMap(jsonDecode(source));
}
