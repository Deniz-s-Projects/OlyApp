import 'api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  /// Stream of notifications received while the app is in the foreground.
  Stream<Map<String, String?>> get foregroundMessages =>
      FirebaseMessaging.onMessage.map((m) {
        final n = m.notification;
        return {'title': n?.title, 'body': n?.body};
      });
}
