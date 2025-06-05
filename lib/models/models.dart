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
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
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
    id: map['id'] as int?,
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
  factory User.fromJsonString(String source) => User.fromMap(jsonDecode(source));
}

@HiveType(typeId: 1)
class MaintenanceRequest {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int userId;
  @HiveField(2)
  final String subject;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  final String status;

  MaintenanceRequest({
    this.id,
    required this.userId,
    required this.subject,
    required this.description,
    DateTime? createdAt,
    this.status = 'open',
  }) : createdAt = createdAt ?? DateTime.now();

  factory MaintenanceRequest.fromMap(Map<String, dynamic> map) {
    return MaintenanceRequest(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      subject: map['subject'] as String,
      description: map['description'] as String,
      createdAt: _parseDate(map['createdAt']),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'subject': subject,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) => MaintenanceRequest.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory MaintenanceRequest.fromJsonString(String source) => MaintenanceRequest.fromMap(jsonDecode(source));
}

@HiveType(typeId: 2)
class Message {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int requestId;
  @HiveField(2)
  final int senderId;
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
    senderId: map['senderId'] as int,
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
  factory Message.fromJsonString(String source) => Message.fromMap(jsonDecode(source));
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
  final List<int> attendees;

  CalendarEvent({
    this.id,
    required this.title,
    required this.date,
    this.description,
    this.attendees = const [],
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) => CalendarEvent(
    id: map['id'] as int?,
    title: map['title'] as String,
    date: _parseDate(map['date']),
    description: map['description'] as String?,
    attendees:
        (map['attendees'] as List<dynamic>? ?? const []).cast<int>(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'description': description,
    'attendees': attendees,
  };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory CalendarEvent.fromJsonString(String source) => CalendarEvent.fromMap(jsonDecode(source));
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
}

@HiveType(typeId: 5)
class Item {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int ownerId;
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
    ownerId: map['ownerId'] as int,
    title: map['title'] as String,
    description: map['description'] as String?,
    imageUrl: map['imageUrl'] as String?,
    price: map['price'] != null ? (map['price'] as num).toDouble() : null,
    isFree: map['isFree'] is bool
        ? map['isFree'] as bool
        : (map['isFree'] as int) == 1,
    category: map['category'] is int
        ? ItemCategory.values[map['category'] as int]
        : ItemCategory.values
            .firstWhere((e) => e.name == map['category'] as String),
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
  factory Item.fromJsonString(String source) => Item.fromMap(jsonDecode(source));
}