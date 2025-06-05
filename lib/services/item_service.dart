import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'api_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for item-related API calls.
class ItemService extends ApiService {
  ItemService({super.client});

  /// Fetches all marketplace items.
  Future<List<Item>> fetchItems() async {
    final box = Hive.isBoxOpen('itemsBox') ? Hive.box('itemsBox') : null;
    try {
      final items = await get('/items', (json) {
        final list = json['data'] as List<dynamic>;
        return list
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      await box?.put('items', items.map((e) => e.toJson()).toList());
      return items;
    } catch (e) {
      final cached = box?.get('items', defaultValue: const <dynamic>[])
          as List?;
      if (cached == null || cached.isEmpty) {
        rethrow;
      }
      return cached
          .map((e) => Item.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  /// Creates a new item listing.
  Future<Item> createItem(Item item, {File? imageFile}) async {
    if (imageFile != null) {
      final request =
          http.MultipartRequest('POST', buildUri('/items'))
            ..fields.addAll(item.toJson().map((k, v) => MapEntry(k, '$v')))
            ..files.add(
              await http.MultipartFile.fromPath('image', imageFile.path),
            );
      final streamed = await client.send(request);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Item.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    }

    return post(
      '/items',
      item.toJson(),
      (json) => Item.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Retrieves messages for the item with [itemId].
  Future<List<Message>> fetchMessages(int itemId) async {
    return get('/items/$itemId/messages', (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Sends a chat [message] for its associated item.
  Future<Message> sendMessage(Message message) async {
    return post(
      '/items/${message.requestId}/messages',
      message.toJson(),
      (json) => Message.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a request to claim or purchase the item with [itemId].
  Future<void> requestItem(int itemId) async {
    await post('/items/$itemId/request', {}, (_) => null);
  }

  /// Updates an existing [item].
  Future<Item> updateItem(Item item) async {
    if (item.id == null) throw ArgumentError('Item id required');
    return post(
      '/items/${item.id}',
      item.toJson(),
      (json) => Item.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Deletes the item with the given [id].
  Future<void> deleteItem(int id) async {
    await post('/items/$id/delete', {}, (_) => null);
  }
}
