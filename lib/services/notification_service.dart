import 'api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';

class NotificationService extends ApiService {
  NotificationService({super.client});

  Future<void> registerToken(String token) async {
    final settings = Hive.box('settingsBox');
    final events =
        settings.get('eventNotifications', defaultValue: true) as bool;
    final announcements =
        settings.get('announcementNotifications', defaultValue: true) as bool;
    if (!events && !announcements) return;
    await post('/notifications/register', {'token': token}, (_) => null);
  }

  Future<int> sendNotification({
    required List<String> tokens,
    required String title,
    required String body,
  }) async {
    final result = await post('/notifications/send', {
      'tokens': tokens,
      'notification': {'title': title, 'body': body},
    }, (json) => json['successCount'] as int);
    return result;
  }

  Future<int> broadcastNotification({
    required String title,
    required String body,
  }) async {
    final result = await post('/notifications/broadcast', {
      'title': title,
      'body': body,
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
