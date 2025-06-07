part of 'models.dart';
@HiveType(typeId: 3)
class CalendarEvent {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final List<String> attendees;
  @HiveField(5)
  final String? location;
  @HiveField(6)
  final String? repeatInterval;
  @HiveField(7)
  final DateTime? repeatUntil;

  CalendarEvent({
    this.id,
    required this.title,
    required this.date,
    this.description,
    this.attendees = const [],
    this.location,
    this.repeatInterval,
    this.repeatUntil,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) => CalendarEvent(
    id: map['id'] as int?,
    title: map['title'] as String,
    date: _parseDate(map['date']),
    description: map['description'] as String?,
    attendees:
        (map['attendees'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    location: map['location'] as String?,
    repeatInterval: map['repeatInterval'] as String?,
    repeatUntil: map['repeatUntil'] != null ? _parseDate(map['repeatUntil']) : null,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'description': description,
    'attendees': attendees,
    'location': location,
    if (repeatInterval != null) 'repeatInterval': repeatInterval,
    if (repeatUntil != null) 'repeatUntil': repeatUntil!.toIso8601String(),
  };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      CalendarEvent.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory CalendarEvent.fromJsonString(String source) =>
      CalendarEvent.fromMap(jsonDecode(source));
}
