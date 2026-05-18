import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';

/// Thin Provider wrappers around the Hive boxes opened at startup in
/// `lib/main.dart`. Pages should resolve boxes through these providers so
/// widget tests can override them with in-memory fakes instead of touching
/// global Hive state.
///
/// These intentionally expose the [Box] directly rather than a typed
/// repository — boxes are already a typed API (`Box<T>`) and adding another
/// layer would just shuffle method names around.

/// `userBox` — current signed-in user record.
final userStorageProvider = Provider<Box<User>>((ref) {
  return Hive.box<User>('userBox');
});

/// `authBox` — opaque session tokens.
final authStorageProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box('authBox');
});

/// `settingsBox` — user-tunable client settings (theme, locale, toggles).
final settingsStorageProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box('settingsBox');
});

/// `notificationsBox` — locally-persisted notification history.
final notificationsStorageProvider = Provider<Box<NotificationRecord>>((ref) {
  return Hive.box<NotificationRecord>('notificationsBox');
});
