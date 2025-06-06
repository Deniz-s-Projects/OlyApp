part of 'models.dart';

class LostItem {
  final String? id;
  final String ownerId;
  final String title;
  final String? description;
  final String? imageUrl;
  final String type;
  final bool resolved;
  final DateTime createdAt;

  LostItem({
    this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.imageUrl,
    this.type = 'lost',
    this.resolved = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory LostItem.fromMap(Map<String, dynamic> map) => LostItem(
        id: map['id']?.toString(),
        ownerId: map['ownerId'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        imageUrl: map['imageUrl'] as String?,
        type: map['type'] as String? ?? 'lost',
        resolved: (map['resolved'] ?? false) as bool,
        createdAt: _parseDate(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'type': type,
        'resolved': resolved,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LostItem.fromJson(Map<String, dynamic> json) =>
      LostItem.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory LostItem.fromJsonString(String source) =>
      LostItem.fromMap(jsonDecode(source));
}
