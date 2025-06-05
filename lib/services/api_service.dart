import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<T> get<T>(String path, T Function(dynamic json) parser) async {
    final response = await _client.get(buildUri(path));
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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return parser(data);
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }
}
