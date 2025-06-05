import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'api_service.dart';

class MaintenanceService extends ApiService {
  MaintenanceService({super.client});

  Future<List<MaintenanceRequest>> fetchRequests() async {
    return get('/maintenance', (json) {
      final list = (json['data'] as List<dynamic>);
      return list
          .map((e) => MaintenanceRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<MaintenanceRequest> createRequest(
    MaintenanceRequest request, {
    File? imageFile,
  }) async {
    if (imageFile != null) {
      final req = http.MultipartRequest('POST', buildUri('/maintenance'))
        ..fields.addAll(
          request.toJson().map((key, value) => MapEntry(key, '$value')),
        )
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final streamed = await client.send(req);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MaintenanceRequest.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    }

    return post('/maintenance', request.toJson(), (json) {
      return MaintenanceRequest.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<List<Message>> fetchMessages(int requestId) async {
    return get('/maintenance/$requestId/messages', (json) {
      final list = (json['data'] as List<dynamic>);
      return list
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Message> sendMessage(Message message) async {
    return post(
      '/maintenance/${message.requestId}/messages',
      message.toJson(),
      (json) => Message.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<MaintenanceRequest> updateStatus(int id, String status) async {
    return put(
      '/maintenance/$id',
      {'status': status},
      (json) => MaintenanceRequest.fromJson(json as Map<String, dynamic>),
    );
  }
}
