part of 'models.dart';

class ChatChannel {
  final String? id;
  final String name;
  final List<String> participants;
  final bool isGroup;

  ChatChannel({
    this.id,
    required this.name,
    this.participants = const [],
    this.isGroup = true,
  });

  factory ChatChannel.fromMap(Map<String, dynamic> map) => ChatChannel(
        id: map['id']?.toString() ?? map['_id']?.toString(),
        name: map['name'] as String? ?? '',
        participants:
            (map['participants'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        isGroup: map['isGroup'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'participants': participants,
        'isGroup': isGroup,
      };

  factory ChatChannel.fromJson(Map<String, dynamic> json) => ChatChannel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory ChatChannel.fromJsonString(String source) => ChatChannel.fromMap(jsonDecode(source));
}
