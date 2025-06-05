
import 'package:hive_flutter/hive_flutter.dart'; 
import 'api_service.dart';

class AuthService extends ApiService {
  AuthService({super.client});

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final data = await post( 
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
      },
      (json) => Map<String, dynamic>.from(json as Map),
    );
    await Hive.box('authBox').put('token', data['token']);
    return data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post( 
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
      (json) => Map<String, dynamic>.from(json as Map),
    ); 
    await Hive.box('authBox').put('token', data['token']);
    return data; 
  }
}
