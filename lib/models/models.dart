import 'dart:convert';
import 'package:hive/hive.dart';

part 'models.g.dart';

DateTime _parseDate(dynamic value) {
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.parse(value);
  throw ArgumentError('Unsupported date format: $value');
}

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  // Path or URL to the user's avatar image
  final String? avatarUrl;
  @HiveField(4)
  final bool isAdmin;

  User({
    this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isAdmin = false,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id']?.toString(),
    name: map['name'] as String,
    email: map['email'] as String,
    avatarUrl: map['avatarUrl'] as String?,
    isAdmin: (map['isAdmin'] ?? false) as bool,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'isAdmin': isAdmin,
  };

  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory User.fromJsonString(String source) =>
      User.fromMap(jsonDecode(source));
}

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

@HiveType(typeId: 2)
class Message {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int requestId;
  @HiveField(2)
  final String senderId;
  @HiveField(3)
  final String content;
  @HiveField(4)
  final DateTime timestamp;

  Message({
    this.id,
    required this.requestId,
    required this.senderId,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Message.fromMap(Map<String, dynamic> map) => Message(
    id: map['id'] as int?,
    requestId: map['requestId'] as int,
    senderId: map['senderId'] as String,
    content: map['content'] as String,
    timestamp: _parseDate(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'requestId': requestId,
    'senderId': senderId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory Message.fromJsonString(String source) =>
      Message.fromMap(jsonDecode(source));
}

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

  CalendarEvent({
    this.id,
    required this.title,
    required this.date,
    this.description,
    this.attendees = const [],
    this.location,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) => CalendarEvent(
    id: map['id'] as int?,
    title: map['title'] as String,
    date: _parseDate(map['date']),
    description: map['description'] as String?,
    attendees:
        (map['attendees'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    location: map['location'] as String?,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'description': description,
    'attendees': attendees,
    'location': location,
  };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) =>
      CalendarEvent.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory CalendarEvent.fromJsonString(String source) =>
      CalendarEvent.fromMap(jsonDecode(source));
}

@HiveType(typeId: 4)
enum ItemCategory {
  @HiveField(0)
  furniture,
  @HiveField(1)
  books,
  @HiveField(2)
  electronics,
  @HiveField(3)
  other,
  @HiveField(4)
  appliances,
  @HiveField(5)
  clothing,
}

@HiveType(typeId: 5)
class Item {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String ownerId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? imageUrl;
  @HiveField(5)
  final double? price;
  @HiveField(6)
  final bool isFree;
  @HiveField(7)
  final ItemCategory category;
  @HiveField(8)
  final DateTime createdAt;

  Item({
    this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.imageUrl,
    this.price,
    this.isFree = false,
    this.category = ItemCategory.other,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Item.fromMap(Map<String, dynamic> map) => Item(
    id: map['id'] as int?,
    ownerId: map['ownerId'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    imageUrl: map['imageUrl'] as String?,
    price: map['price'] != null ? (map['price'] as num).toDouble() : null,
    isFree:
        map['isFree'] is bool
            ? map['isFree'] as bool
            : (map['isFree'] as int) == 1,
    category:
        map['category'] is int
            ? ItemCategory.values[map['category'] as int]
            : ItemCategory.values.firstWhere(
              (e) => e.name == map['category'] as String,
            ),
    createdAt: _parseDate(map['createdAt']),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'price': price,
    'isFree': isFree,
    'category': category.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory Item.fromJsonString(String source) =>
      Item.fromMap(jsonDecode(source));
}

class BulletinPost {
  final int? id;
  final String userId;
  final String content;
  final DateTime date;

  BulletinPost({this.id, required this.userId, required this.content, DateTime? date})
    : date = date ?? DateTime.now();

  factory BulletinPost.fromMap(Map<String, dynamic> map) => BulletinPost(
    id: map['id'] as int?,
    userId: map['userId'] as String,
    content: map['content'] as String,
    date: _parseDate(map['date']),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'content': content,
    'date': date.toIso8601String(),
  };

  factory BulletinPost.fromJson(Map<String, dynamic> json) =>
      BulletinPost.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

class BulletinComment {
  final int? id;
  final int postId;
  final String userId;
  final String content;
  final DateTime date;

  BulletinComment({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory BulletinComment.fromMap(Map<String, dynamic> map) => BulletinComment(
    id: map['id'] as int?,
    postId: map['postId'] as int,
    userId: map['userId'] as String,
    content: map['content'] as String,
    date: _parseDate(map['date']),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'postId': postId,
    'userId': userId,
    'content': content,
    'date': date.toIso8601String(),
  };

  factory BulletinComment.fromJson(Map<String, dynamic> json) =>
      BulletinComment.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

class EventComment {
  final String? id;
  final int eventId;
  final String content;
  final DateTime date;

  EventComment({
    this.id,
    required this.eventId,
    required this.content,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory EventComment.fromMap(Map<String, dynamic> map) => EventComment(
        id: map['id'] as String?,
        eventId: map['eventId'] is int
            ? map['eventId'] as int
            : int.parse(map['eventId'].toString()),
        content: map['content'] as String,
        date: _parseDate(map['date']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'eventId': eventId,
        'content': content,
        'date': date.toIso8601String(),
      };

  factory EventComment.fromJson(Map<String, dynamic> json) =>
      EventComment.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

@HiveType(typeId: 6)
class NotificationRecord {
  @HiveField(0)
  final String? title;
  @HiveField(1)
  final String? body;
  @HiveField(2)
  final DateTime timestamp;

  NotificationRecord({
    this.title,
    this.body,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NotificationRecord.fromMap(Map<String, dynamic> map) =>
      NotificationRecord(
        title: map['title'] as String?,
        body: map['body'] as String?,
        timestamp: _parseDate(map['timestamp']),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
      };

  factory NotificationRecord.fromJson(Map<String, dynamic> json) =>
      NotificationRecord.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory NotificationRecord.fromJsonString(String source) =>
      NotificationRecord.fromMap(jsonDecode(source));
}
@HiveType(typeId: 7)
class TransitStop {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  TransitStop({required this.id, required this.name});

  factory TransitStop.fromMap(Map<String, dynamic> map) => TransitStop(
        id: map['id'].toString(),
        name: map['name'] as String,
      );

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory TransitStop.fromJson(Map<String, dynamic> json) =>
      TransitStop.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

class TransitDeparture {
  final String line;
  final String destination;
  final DateTime time;

  TransitDeparture({
    required this.line,
    required this.destination,
    required this.time,
  });

  factory TransitDeparture.fromMap(Map<String, dynamic> map) => TransitDeparture(
        line: map['line'] as String,
        destination: map['destination'] as String,
        time: _parseDate(map['time']),
      );

  Map<String, dynamic> toMap() => {
        'line': line,
        'destination': destination,
        'time': time.toIso8601String(),
      };
}
