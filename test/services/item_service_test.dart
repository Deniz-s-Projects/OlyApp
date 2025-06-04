import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:oly_app/services/item_service.dart';
import 'package:oly_app/models/models.dart';

void main() {
  group('ItemService', () {
    test('fetchItems parses list correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, '/api/items');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 1,
                'ownerId': 1,
                'title': 'Chair',
                'description': null,
                'imageUrl': null,
                'price': null,
                'isFree': false,
                'category': 'furniture',
                'createdAt': '1970-01-01T00:00:00.000Z'
              }
            ]
          }),
          200,
        );
      });

      final service = ItemService(client: mockClient);
      final items = await service.fetchItems();
      expect(items, hasLength(1));
      expect(items.first.id, 1);
      expect(items.first.title, 'Chair');
    });

    test('createItem sends POST and parses item', () async {
      final itemInput = Item(ownerId: 1, title: 'Table');
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, '/api/items');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['title'], itemInput.title);
        return http.Response(
          jsonEncode({
            'data': {
              'id': 2,
              ...itemInput.toJson(),
            }
          }),
          201,
        );
      });

      final service = ItemService(client: mockClient);
      final item = await service.createItem(itemInput);
      expect(item.id, 2);
      expect(item.title, 'Table');
    });

    test('fetchMessages parses list correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, '/api/items/1/messages');
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'requestId': 1,
              'senderId': 2,
              'content': 'Hi',
              'timestamp': 0,
            },
          ]),
          200,
        );
      });

      final service = ItemService(client: mockClient);
      final messages = await service.fetchMessages(1);
      expect(messages, hasLength(1));
      expect(messages.first.content, 'Hi');
    });

    test('sendMessage posts message', () async {
      final input = Message(requestId: 1, senderId: 1, content: 'Hello');
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, '/api/items/1/messages');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['content'], input.content);
        return http.Response(jsonEncode({'id': 2, ...input.toJson()}), 201);
      });

      final service = ItemService(client: mockClient);
      final message = await service.sendMessage(input);
      expect(message.id, 2);
    });

    test('throws on non-success status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('error', 500);
      });

      final service = ItemService(client: mockClient);
      expect(service.fetchItems(), throwsException);
    });
  });
}
