part of 'models.dart';
@HiveType(typeId: 1)
class MaintenanceRequest {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String subject;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final String status;
  @HiveField(6)
  final String? imageUrl;

  MaintenanceRequest({
    this.id,
    required this.userId,
    required this.subject,
    required this.description,
    DateTime? createdAt,
    this.status = 'open',
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MaintenanceRequest.fromMap(Map<String, dynamic> map) {
    return MaintenanceRequest(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      subject: map['subject'] as String,
      description: map['description'] as String,
      createdAt: _parseDate(map['createdAt']),
      status: map['status'] as String,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'subject': subject,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
    'imageUrl': imageUrl,
  };

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) =>
      MaintenanceRequest.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory MaintenanceRequest.fromJsonString(String source) =>
      MaintenanceRequest.fromMap(jsonDecode(source));
}
