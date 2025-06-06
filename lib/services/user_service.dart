import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'api_service.dart';

class UserService extends ApiService {
  UserService({super.client});

  Future<User> updateProfile(User user) async {
    return put(
      '/users/me',
      user.toJson(),
      (json) => User.fromJson((json['data'] as Map<String, dynamic>)),
    );
  }

  /// Uploads an avatar image and returns the server path.
  Future<String> uploadAvatar(File file) async {
    final request = http.MultipartRequest('POST', buildUri('/users/me/avatar'))
      ..files.add(await http.MultipartFile.fromPath('avatar', file.path));
    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['path'] as String;
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }

  Future<void> deleteAccount() async {
    await delete('/users/me', (_) => null);
  }
}
