part of 'models.dart';

class Club {
  final String? id;
  final String name;
  final String? description;
  final List<String> members;
  final String? channelId;

  Club({
    this.id,
    required this.name,
    this.description,
    this.members = const [],
    this.channelId,
  });

  factory Club.fromMap(Map<String, dynamic> map) => Club(
    id: map['id']?.toString() ?? map['_id']?.toString(),
    name: map['name'] as String? ?? '',
    description: map['description'] as String?,
    members: (map['members'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    channelId: map['channelId']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'members': members,
    'channelId': channelId,
  };

  factory Club.fromJson(Map<String, dynamic> json) => Club.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
