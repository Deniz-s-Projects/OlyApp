import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

/// Base class for API services.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  http.Client get client => _client;
  // Base URL of the Node.js/Express backend
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  Uri buildUri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse(
      baseUrl,
    ).replace(path: '/api$path', queryParameters: query);
  }

  Map<String, String> _authHeaders([Map<String, String>? headers]) {
    final box = Hive.isBoxOpen('authBox') ? Hive.box('authBox') : null;
    final token = box?.get('token') as String?;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };
  }

  Future<T> get<T>(String path, T Function(dynamic json) parser) async {
    final response = await _client.get(
      buildUri(path),
      headers: _authHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return parser(data);
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }

  Future<T> post<T>(
    String path,
    dynamic body,
    T Function(dynamic json) parser,
  ) async {
    final response = await _client.post(
      buildUri(path),
      headers: _authHeaders({'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return parser(data);
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }

  Future<T> put<T>(
    String path,
    dynamic body,
    T Function(dynamic json) parser,
  ) async {
    final response = await _client.put(
      buildUri(path),
      headers: _authHeaders({'Content-Type': 'application/json'}),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return parser(data);
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }

  Future<T> delete<T>(String path, T Function(dynamic json) parser) async {
    final response = await _client.delete(
      buildUri(path),
      headers: _authHeaders(),
    );
    if (response.statusCode == 200) {
      final body = response.body.isEmpty ? '{}' : response.body;
      final data = jsonDecode(body);
      return parser(data);
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }
}
