import 'api_service.dart';

class AuthService extends ApiService {
  AuthService({super.client});

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    return post(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
      },
      (json) => Map<String, dynamic>.from(json as Map),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
      (json) => Map<String, dynamic>.from(json as Map),
    );
  }
}
