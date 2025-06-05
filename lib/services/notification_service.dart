import 'api_service.dart';

class NotificationService extends ApiService {
  NotificationService({super.client});

  Future<void> registerToken(String token) async {
    await post('/notifications/register', {'token': token}, (_) => null);
  }
}
