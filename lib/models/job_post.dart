part of 'models.dart';

class JobPost {
  final String? id;
  final String ownerId;
  final String title;
  final String description;
  final String? pay;
  final String? contact;
  final DateTime createdAt;

  JobPost({
    this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    this.pay,
    this.contact,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory JobPost.fromMap(Map<String, dynamic> map) => JobPost(
    id: map['id']?.toString() ?? map['_id']?.toString(),
    ownerId: map['ownerId']?.toString() ?? '',
    title: map['title'] as String? ?? '',
    description: map['description'] as String? ?? '',
    pay: map['pay'] as String?,
    contact: map['contact'] as String?,
    createdAt: map['createdAt'] != null
        ? _parseDate(map['createdAt'])
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    if (pay != null) 'pay': pay,
    if (contact != null) 'contact': contact,
    'createdAt': createdAt.toIso8601String(),
  };

  factory JobPost.fromJson(Map<String, dynamic> json) => JobPost.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
