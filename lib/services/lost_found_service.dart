import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'api_service.dart';

/// Service for lost & found related API calls.
class LostFoundService extends ApiService {
  LostFoundService({super.client});

  /// Fetches all lost and found posts.
  Future<List<LostItem>> fetchItems() async {
    return get('/lostfound', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => LostItem.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Creates a new lost or found post.
  Future<LostItem> createItem(LostItem item, {File? imageFile}) async {
    if (imageFile != null) {
      final request =
          http.MultipartRequest('POST', buildUri('/lostfound'))
            ..fields.addAll(item.toJson().map((k, v) => MapEntry(k, '$v')))
            ..files.add(
              await http.MultipartFile.fromPath('image', imageFile.path),
            );
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
}
