part of 'models.dart';

class ServiceListing {
  final int? id;
  final String userId;
  final String title;
  final String description;
  final String? contact;
  final DateTime createdAt;

  ServiceListing({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.contact,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ServiceListing.fromMap(Map<String, dynamic> map) => ServiceListing(
        id: map['id'] as int?,
        userId: map['userId'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        contact: map['contact'] as String?,
        createdAt: _parseDate(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'contact': contact,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ServiceListing.fromJson(Map<String, dynamic> json) =>
      ServiceListing.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
