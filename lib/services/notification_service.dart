import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';

import '../providers/route_request_provider.dart';
import 'api_service.dart';

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
    Map<String, String>? data,
  }) async {
    final result = await post('/notifications/send', {
      'tokens': tokens,
      'notification': {'title': title, 'body': body},
      if (data != null) 'data': data,
    }, (json) => json['successCount'] as int);
    return result;
  }

  Future<int> broadcastNotification({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final result = await post('/notifications/broadcast', {
      'title': title,
      'body': body,
      if (data != null) 'data': data,
    }, (json) => json['successCount'] as int);
    return result;
  }

  /// Stream of notifications received while the app is in the foreground.
  Stream<Map<String, String?>> get foregroundMessages =>
      FirebaseMessaging.onMessage.map((m) {
        final n = m.notification;
        return {'title': n?.title, 'body': n?.body};
      });

  /// Stream of [RouteRequest]s parsed from notification taps (background
  /// → foreground) and the initial-message (cold start). Only emits when
  /// the message data carries a recognised `route` key.
  Stream<RouteRequest> get routeRequests async* {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    final initialReq = RouteRequest.fromFcmData(initial?.data);
    if (initialReq != null) yield initialReq;
    yield* FirebaseMessaging.onMessageOpenedApp
        .map((m) => RouteRequest.fromFcmData(m.data))
        .where((r) => r != null)
        .cast<RouteRequest>();
  }
}
