import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:oly_app/services/bulletin_service.dart';
import 'package:oly_app/models/models.dart';

const apiUrl =
    String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

void main() {
  group('BulletinService', () {
    test('fetchPosts parses list correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/bulletin');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 1,
                'content': 'Hello',
                'date': '1970-01-01T00:00:00.000Z'
              }
            ]
          }),
          200,
        );
      });

      final service = BulletinService(client: mockClient);
      final posts = await service.fetchPosts();
      expect(posts, hasLength(1));
      expect(posts.first.content, 'Hello');
    });

    test('addPost sends POST and parses result', () async {
      final input = BulletinPost(content: 'Hi', date: DateTime.fromMillisecondsSinceEpoch(0));
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.origin, Uri.parse(apiUrl).origin);
        expect(request.url.path, '/api/bulletin');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['content'], input.content);
        return http.Response(
          jsonEncode({
            'data': {'id': 2, ...input.toJson()}
          }),
          201,
        );
      });

      final service = BulletinService(client: mockClient);
      final result = await service.addPost(input);
      expect(result.id, 2);
      expect(result.content, input.content);
    });

    test('fetchComments parses list correctly', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.path, '/api/bulletin/1/comments');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 1,
                'postId': 1,
                'content': 'c',
                'date': '1970-01-01T00:00:00.000Z'
              }
            ]
          }),
          200,
        );
      });

      final service = BulletinService(client: mockClient);
      final comments = await service.fetchComments(1);
      expect(comments, hasLength(1));
      expect(comments.first.content, 'c');
    });

    test('addComment posts comment', () async {
      final input = BulletinComment(postId: 1, content: 'x');
      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.path, '/api/bulletin/1/comments');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['content'], input.content);
        return http.Response(
          jsonEncode({
            'data': {'id': 3, ...input.toJson()}
          }),
          201,
        );
      });

      final service = BulletinService(client: mockClient);
      final comment = await service.addComment(input);
      expect(comment.id, 3);
      expect(comment.content, input.content);
    });

    test('updatePost sends PUT', () async {
      final input = BulletinPost(id: 1, content: 'n', date: DateTime.fromMillisecondsSinceEpoch(0));
      final mockClient = MockClient((request) async {
        expect(request.method, equals('PUT'));
        expect(request.url.path, '/api/bulletin/1');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['content'], input.content);
        return http.Response(jsonEncode({'data': input.toJson()}), 200);
      });
      final service = BulletinService(client: mockClient);
      final res = await service.updatePost(input);
      expect(res.content, 'n');
    });

    test('deletePost sends DELETE', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(request.url.path, '/api/bulletin/1');
        return http.Response('{}', 200);
      });
      final service = BulletinService(client: mockClient);
      await service.deletePost(1);
    });

    test('throws on error status', () async {
      final mockClient = MockClient((_) async => http.Response('err', 500));
      final service = BulletinService(client: mockClient);
      expect(service.fetchPosts(), throwsException);
    });
  });
}
