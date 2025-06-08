part of 'models.dart';

class TutoringPost {
  final String? id;
  final String userId;
  final String subject;
  final String description;
  final bool isOffering;
  final String contactUserId;
  final DateTime createdAt;

  TutoringPost({
    this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.isOffering,
    required this.contactUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TutoringPost.fromMap(Map<String, dynamic> map) => TutoringPost(
    id: map['id']?.toString() ?? map['_id']?.toString(),
    userId: map['userId']?.toString() ?? '',
    subject: map['subject'] as String? ?? '',
    description: map['description'] as String? ?? '',
    isOffering: map['isOffering'] is bool
        ? map['isOffering'] as bool
        : map['isOffering'].toString() == 'true' || map['isOffering'] == 1,
    contactUserId: map['contactUserId']?.toString() ?? '',
    createdAt: map['createdAt'] != null
        ? _parseDate(map['createdAt'])
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'subject': subject,
    'description': description,
    'isOffering': isOffering,
    'contactUserId': contactUserId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory TutoringPost.fromJson(Map<String, dynamic> json) =>
      TutoringPost.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
