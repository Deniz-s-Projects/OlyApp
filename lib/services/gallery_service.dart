import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import 'api_service.dart';

class GalleryService extends ApiService {
  GalleryService({super.client});

  Future<List<GalleryImage>> fetchImages() async {
    return get('/gallery', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => GalleryImage.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<GalleryImage> uploadImage(File file) async {
    final request = http.MultipartRequest('POST', buildUri('/gallery'))
      ..files.add(await http.MultipartFile.fromPath('image', file.path));
    request.headers.addAll(_authHeaders());
    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return GalleryImage.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Request failed: ${response.statusCode}');
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
