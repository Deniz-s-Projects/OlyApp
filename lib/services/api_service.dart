import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

/// Thrown when the server responds with HTTP 401. Callers can catch this
/// type to render a session-expired UI; the global
/// [ApiService.onUnauthorized] hook fires before this is raised so the
/// app can also clear the session and bounce to the login screen.
class UnauthorizedException implements Exception {
  const UnauthorizedException();
  @override
  String toString() => 'Unauthorized';
}

/// Base class for API services.
class ApiService {
  ApiService({
    http.Client? client,
    String? Function()? tokenSource,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _tokenSource = tokenSource,
        _timeout = timeout ?? const Duration(seconds: 15);

  final http.Client _client;
  final String? Function()? _tokenSource;
  final Duration _timeout;

  http.Client get client => _client;

  // Base URL of the Node.js/Express backend
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// App-wide hook fired when the server returns 401. Set once at boot in
  /// `OlyAppState.initState` so a stale token triggers logout instead of
  /// surfacing as a generic SnackBar. Kept as a static (rather than
  /// per-instance) because every service shares the same logout policy
  /// and the existing service constructors take no arguments.
  static void Function()? onUnauthorized;

  Uri buildUri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse(
      baseUrl,
    ).replace(path: '/api$path', queryParameters: query);
  }

  Map<String, String> _authHeaders([Map<String, String>? headers]) {
    final token = _readToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };
  }

  String? _readToken() {
    final source = _tokenSource;
    if (source != null) return source();
    final box = Hive.isBoxOpen('authBox') ? Hive.box('authBox') : null;
    return box?.get('token') as String?;
  }

  /// Wraps a raw http call with a timeout and a 401 → logout hook.
  /// Returns the response for 2xx/non-401 statuses; the caller is still
  /// responsible for status-specific error mapping via [_errorFromResponse].
  Future<http.Response> _send(
    Future<http.Response> Function() send,
  ) async {
    final http.Response response;
    try {
      response = await send().timeout(_timeout);
    } on TimeoutException {
      throw Exception('Request timed out');
    }
    if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw const UnauthorizedException();
    }
    return response;
  }

  Exception _errorFromResponse(http.Response response) {
    try {
      if (response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        if (json is Map && json['error'] is String) {
          return Exception(json['error']);
        }
      }
    } catch (_) {}
    return Exception('Request failed: ${response.statusCode}');
  }

  Future<T> get<T>(String path, T Function(dynamic json) parser) async {
    final response = await _send(
      () => _client.get(buildUri(path), headers: _authHeaders()),
    );
    if (response.statusCode == 200) {
      return parser(jsonDecode(response.body));
    }
    throw _errorFromResponse(response);
  }

  Future<T> post<T>(
    String path,
    dynamic body,
    T Function(dynamic json) parser,
  ) async {
    final response = await _send(
      () => _client.post(
        buildUri(path),
        headers: _authHeaders({'Content-Type': 'application/json'}),
        body: jsonEncode(body),
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return parser(jsonDecode(response.body));
    }
    throw _errorFromResponse(response);
  }

  Future<T> put<T>(
    String path,
    dynamic body,
    T Function(dynamic json) parser,
  ) async {
    final response = await _send(
      () => _client.put(
        buildUri(path),
        headers: _authHeaders({'Content-Type': 'application/json'}),
        body: jsonEncode(body),
      ),
    );
    if (response.statusCode == 200) {
      return parser(jsonDecode(response.body));
    }
    throw _errorFromResponse(response);
  }

  Future<T> delete<T>(String path, T Function(dynamic json) parser) async {
    final response = await _send(
      () => _client.delete(buildUri(path), headers: _authHeaders()),
    );
    if (response.statusCode == 200) {
      final body = response.body.isEmpty ? '{}' : response.body;
      return parser(jsonDecode(body));
    }
    throw _errorFromResponse(response);
  }
}
