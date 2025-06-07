part of 'models.dart';

class StudyGroup {
  final String? id;
  final String topic;
  final String? description;
  final DateTime? meetingTime;
  final String creatorId;
  final List<String> memberIds;

  StudyGroup({
    this.id,
    required this.topic,
    this.description,
    this.meetingTime,
    required this.creatorId,
    this.memberIds = const [],
  });

  factory StudyGroup.fromMap(Map<String, dynamic> map) => StudyGroup(
        id: map['id']?.toString() ?? map['_id']?.toString(),
        topic: map['topic'] as String? ?? '',
        description: map['description'] as String?,
        meetingTime:
            map['meetingTime'] != null ? _parseDate(map['meetingTime']) : null,
        creatorId: map['creatorId']?.toString() ?? '',
        memberIds: (map['memberIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'topic': topic,
        'description': description,
        if (meetingTime != null) 'meetingTime': meetingTime!.toIso8601String(),
        'creatorId': creatorId,
        'memberIds': memberIds,
      };

  factory StudyGroup.fromJson(Map<String, dynamic> json) =>
      StudyGroup.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
