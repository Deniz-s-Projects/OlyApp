import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import 'api_service.dart';

/// Service for lost & found related API calls.
class LostFoundService extends ApiService {
  LostFoundService({super.client});

  /// Fetches lost and found posts with optional filters.
  Future<List<LostItem>> fetchItems({
    String? search,
    String? type,
    bool? resolved,
  }) async {
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (resolved != null) query['resolved'] = '$resolved';

    final uri = buildUri('/lostfound', query.isEmpty ? null : query);
    final res = await client.get(uri, headers: _authHeaders());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list
          .map((e) => LostItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Request failed: ${res.statusCode}');
  }

  /// Creates a new lost or found post.
  Future<LostItem> createItem(LostItem item, {File? imageFile}) async {
    if (imageFile != null) {
      final request = http.MultipartRequest('POST', buildUri('/lostfound'))
        ..fields.addAll(item.toJson().map((k, v) => MapEntry(k, '$v')))
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final streamed = await client.send(request);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LostItem.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    }

    return post(
      '/lostfound',
      item.toJson(),
      (json) => LostItem.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Retrieves the chat messages for the post with [id].
  Future<List<Message>> fetchMessages(String id) async {
    return get('/lostfound/$id/messages', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Sends a chat [msg] for the post with [id].
  Future<Message> sendMessage(String id, Message msg) async {
    return post(
      '/lostfound/$id/messages',
      msg.toJson(),
      (json) => Message.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Marks the item with [id] as resolved.
  Future<void> resolveItem(String id) async {
    await post('/lostfound/$id/resolve', {}, (_) => null);
  }

  /// Updates an existing lost/found [item].
  Future<LostItem> updateItem(LostItem item) async {
    if (item.id == null) throw ArgumentError('Item id required');
    return post(
      '/lostfound/${item.id}',
      item.toJson(),
      (json) => LostItem.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Deletes the lost/found post with [id].
  Future<void> deleteItem(String id) async {
    await post('/lostfound/$id/delete', {}, (_) => null);
  }

  Map<String, String> _authHeaders([Map<String, String>? headers]) {
    final box = Hive.isBoxOpen('authBox') ? Hive.box('authBox') : null;
    final token = box?.get('token') as String?;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };
  }
}
