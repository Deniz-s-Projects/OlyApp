import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'api_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DocumentService extends ApiService {
  DocumentService({super.client});

  Future<List<Document>> fetchDocuments() async {
    return get('/documents', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Document> uploadDocument(File file) async {
    final request = http.MultipartRequest('POST', buildUri('/documents'))
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    request.headers.addAll(_authHeaders());
    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Document.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Request failed: ${response.statusCode}');
  }

  Future<Uint8List> downloadDocument(String url) async {
    final uri = url.startsWith('http') ? Uri.parse(url) : buildUri('')
        .replace(path: url.startsWith('/') ? url : '/$url');
    final res = await client.get(uri, headers: _authHeaders());
    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
    throw Exception('Failed to download');
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
