import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';
import 'api_service.dart';

class DirectoryService extends ApiService {
  DirectoryService({super.client});

  String _cacheKey(String? search) => 'users_${search ?? ''}';

  List<User> loadCachedUsers({String? search}) {
    final box = Hive.isBoxOpen('directoryBox') ? Hive.box('directoryBox') : null;
    final cached = box?.get(_cacheKey(search), defaultValue: const <dynamic>[])
        as List?;
    if (cached == null || cached.isEmpty) return [];
    return cached
        .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<User>> fetchUsers({String? search}) async {
    final box = Hive.isBoxOpen('directoryBox') ? Hive.box('directoryBox') : null;
    try {
      final uri = buildUri('/directory',
          search != null && search.isNotEmpty ? {'search': search} : null);
      final res = await client.get(uri, headers: _authHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;
        final users =
            list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
        await box?.put(
          _cacheKey(search),
          users.map((u) => u.toJson()).toList(),
        );
        return users;
      }
      throw Exception('Request failed: ${res.statusCode}');
    } catch (_) {
      final cached = box?.get(_cacheKey(search), defaultValue: const <dynamic>[])
          as List?;
      if (cached == null || cached.isEmpty) rethrow;
      return cached
          .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Future<List<Message>> fetchMessages(String userId) async {
    return get('/directory/$userId/messages', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Message> sendMessage(String userId, String content) async {
    return post('/directory/$userId/messages', {'content': content}, (json) {
      return Message.fromJson(json['data'] as Map<String, dynamic>);
    });
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
