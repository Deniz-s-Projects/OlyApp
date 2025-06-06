import 'dart:convert';
import 'package:hive/hive.dart';

part 'models.g.dart';
part 'user.dart';
part 'maintenance_request.dart';
part 'message.dart';
part 'calendar_event.dart';
part 'item.dart';
part 'service_listing.dart';
part 'bulletin_post.dart';
part 'bulletin_comment.dart';
part 'event_comment.dart';
part 'notification_record.dart';
part 'transit.dart';
part 'poll.dart';
part 'lost_item.dart';

DateTime _parseDate(dynamic value) {
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.parse(value);
  throw ArgumentError('Unsupported date format: $value');
}
