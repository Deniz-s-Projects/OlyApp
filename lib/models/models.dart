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
part 'chat_channel.dart';
part 'club.dart';
part 'wiki_article.dart';
part 'emergency_contact.dart';
part 'document.dart';
part 'suggestion.dart';
part 'gallery_image.dart';
part 'study_group.dart';
part 'tutoring_post.dart';
part 'job_post.dart';
part 'security_report.dart';
part 'noise_report.dart';

DateTime _parseDate(dynamic value) {
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.parse(value);
  throw ArgumentError('Unsupported date format: $value');
}
