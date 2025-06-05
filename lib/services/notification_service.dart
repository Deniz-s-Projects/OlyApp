import 'api_service.dart';

class NotificationService extends ApiService {
  NotificationService({super.client});

  Future<void> registerToken(String token) async {
    await post('/notifications/register', {'token': token}, (_) => null);
  }

  Future<int> sendNotification({required List<String> tokens, required String title, required String body}) async {
    final result = await post('/notifications/send', {
      'tokens': tokens,
      'notification': {'title': title, 'body': body},
    }, (json) => json['successCount'] as int);
    return result;
  }
}
