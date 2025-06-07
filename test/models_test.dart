import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';

void main() {
  group('User', () {
    final user = User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      avatarUrl: 'https://example.com/avatar.png',
      isAdmin: true,
      isListed: false,
    );

    final userMap = {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'avatarUrl': 'https://example.com/avatar.png',
      'isAdmin': true,
      'isListed': false,
    };

    test('toMap/fromMap round trip', () {
      expect(user.toMap(), userMap);
      final copy = User.fromMap(user.toMap());
      expect(copy.toMap(), userMap);
    });

    test('toJsonString/fromJsonString', () {
      final jsonStr = user.toJsonString();
      expect(jsonDecode(jsonStr), userMap);
      final copy = User.fromJsonString(jsonStr);
      expect(copy.toMap(), userMap);
    });
  });

  group('MaintenanceRequest', () {
    final created = DateTime.utc(2024, 1, 1, 12, 0, 0);
    final request = MaintenanceRequest(
      id: 2,
      userId: '3',
      subject: 'Leaky faucet',
      description: 'Kitchen sink leaks',
      createdAt: created,
      status: 'open',
      imageUrl: 'img.png',
    );

    final requestMap = {
      'id': 2,
      'userId': '3',
      'subject': 'Leaky faucet',
      'description': 'Kitchen sink leaks',
      'createdAt': created.toIso8601String(),
      'status': 'open',
      'imageUrl': 'img.png',
    };

    test('toMap/fromMap round trip', () {
      expect(request.toMap(), requestMap);
      final copy = MaintenanceRequest.fromMap(request.toMap());
      expect(copy.toMap(), requestMap);
    });

    test('toJsonString/fromJsonString', () {
      final jsonStr = request.toJsonString();
      expect(jsonDecode(jsonStr), requestMap);
      final copy = MaintenanceRequest.fromJsonString(jsonStr);
      expect(copy.toMap(), requestMap);
    });
  });

  group('Message', () {
    final timestamp = DateTime.utc(2024, 1, 2, 8, 30);
    final message = Message(
      id: 3,
      requestId: 10,
      senderId: '4',
      content: 'Hello world',
      timestamp: timestamp,
    );

    final messageMap = {
      'id': 3,
      'requestId': 10,
      'senderId': '4',
      'content': 'Hello world',
      'timestamp': timestamp.toIso8601String(),
    };

    test('toMap/fromMap round trip', () {
      expect(message.toMap(), messageMap);
      final copy = Message.fromMap(message.toMap());
      expect(copy.toMap(), messageMap);
    });

    test('toJsonString/fromJsonString', () {
      final jsonStr = message.toJsonString();
      expect(jsonDecode(jsonStr), messageMap);
      final copy = Message.fromJsonString(jsonStr);
      expect(copy.toMap(), messageMap);
    });
  });

  group('CalendarEvent', () {
    final eventDate = DateTime.utc(2025, 5, 20, 9);
    final event = CalendarEvent(
      id: 4,
      title: 'Meeting',
      date: eventDate,
      description: 'Project discussion',
      attendees: const ['1', '2'],
      location: 'locA',
      category: 'work',
    );

    final eventMap = {
      'id': 4,
      'title': 'Meeting',
      'date': eventDate.toIso8601String(),
      'description': 'Project discussion',
      'attendees': const ['1', '2'],
      'location': 'locA',
      'category': 'work',
    };

    test('toMap/fromMap round trip', () {
      expect(event.toMap(), eventMap);
      final copy = CalendarEvent.fromMap(event.toMap());
      expect(copy.toMap(), eventMap);
    });

    test('toJsonString/fromJsonString', () {
      final jsonStr = event.toJsonString();
      expect(jsonDecode(jsonStr), eventMap);
      final copy = CalendarEvent.fromJsonString(jsonStr);
      expect(copy.toMap(), eventMap);
    });
  });

  group('Item', () {
    final created = DateTime.utc(2023, 12, 31, 23, 59, 59);
    final item = Item(
      id: 5,
      ownerId: '6',
      title: 'Chair',
      description: 'Comfy chair',
      imageUrl: 'https://example.com/chair.png',
      price: 20.5,
      isFree: false,
      category: ItemCategory.furniture,
      createdAt: created,
      completed: false,
      ratings: const [],
    );

    final itemMap = {
      'id': 5,
      'ownerId': '6',
      'title': 'Chair',
      'description': 'Comfy chair',
      'imageUrl': 'https://example.com/chair.png',
      'price': 20.5,
      'isFree': false,
      'category': ItemCategory.furniture.name,
      'createdAt': created.toIso8601String(),
      'completed': false,
      'ratings': const [],
    };

    test('toMap/fromMap round trip', () {
      expect(item.toMap(), itemMap);
      final copy = Item.fromMap(item.toMap());
      expect(copy.toMap(), itemMap);
    });

    test('toJsonString/fromJsonString', () {
      final jsonStr = item.toJsonString();
      expect(jsonDecode(jsonStr), itemMap);
      final copy = Item.fromJsonString(jsonStr);
      expect(copy.toMap(), itemMap);
    });
  });

  group('NotificationRecord', () {
    final timestamp = DateTime.utc(2024, 1, 1, 12);
    final record = NotificationRecord(
      title: 'Hello',
      body: 'World',
      timestamp: timestamp,
    );

    final recordMap = {
      'title': 'Hello',
      'body': 'World',
      'timestamp': timestamp.toIso8601String(),
    };

    test('toMap/fromMap round trip', () {
      expect(record.toMap(), recordMap);
      final copy = NotificationRecord.fromMap(record.toMap());
      expect(copy.toMap(), recordMap);
    });

    test('toJsonString/fromJsonString', () {
      final jsonStr = record.toJsonString();
      expect(jsonDecode(jsonStr), recordMap);
      final copy = NotificationRecord.fromJsonString(jsonStr);
      expect(copy.toMap(), recordMap);
    });
  });
}
