part of 'models.dart';

class SecurityReport {
  final String? id;
  final String reporterId;
  final String description;
  final String location;
  final DateTime timestamp;

  SecurityReport({
    this.id,
    required this.reporterId,
    required this.description,
    required this.location,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SecurityReport.fromMap(Map<String, dynamic> map) => SecurityReport(
        id: map['id']?.toString(),
        reporterId: map['reporterId'] as String,
        description: map['description'] as String,
        location: map['location'] as String,
        timestamp: _parseDate(map['timestamp']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'reporterId': reporterId,
        'description': description,
        'location': location,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SecurityReport.fromJson(Map<String, dynamic> json) =>
      SecurityReport.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
