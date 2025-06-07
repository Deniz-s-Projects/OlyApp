import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import 'api_service.dart';

class UserService extends ApiService {
  UserService({super.client});

  Future<List<User>> fetchUsers({String? search}) async {
    final uri = buildUri('/users',
        search != null && search.isNotEmpty ? {'search': search} : null);
    final res = await client.get(uri, headers: _authHeaders());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Request failed: ${res.statusCode}');
  }

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

  Future<User> updateUser(User user) async {
    if (user.id == null) throw ArgumentError('id required');
    return put(
      '/users/${user.id}',
      user.toJson(),
      (json) => User.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteUser(String id) async {
    await delete('/users/$id', (_) => null);
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
