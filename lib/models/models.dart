import 'dart:convert';
import 'package:hive/hive.dart';

part 'models.g.dart';

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

  User({
    this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String,
    avatarUrl: map['avatarUrl'] as String?,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
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
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'subject': subject,
    'description': description,
    'createdAt': createdAt.millisecondsSinceEpoch,
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
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'requestId': requestId,
    'senderId': senderId,
    'content': content,
    'timestamp': timestamp.millisecondsSinceEpoch,
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

  CalendarEvent({
    this.id,
    required this.title,
    required this.date,
    this.description,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) => CalendarEvent(
    id: map['id'] as int?,
    title: map['title'] as String,
    date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    description: map['description'] as String?,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'date': date.millisecondsSinceEpoch,
    'description': description,
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
    isFree: (map['isFree'] as int) == 1,
    category: ItemCategory.values[map['category'] as int],
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'price': price,
    'isFree': isFree ? 1 : 0,
    'category': category.index,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory Item.fromJsonString(String source) => Item.fromMap(jsonDecode(source));
}