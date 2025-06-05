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
}
