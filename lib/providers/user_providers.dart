import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

/// The user currently signed in, or `null` if no session is active.
///
/// Backed by the Hive `userBox` populated by the login / register / profile
/// flows in `lib/main.dart`, `login_page.dart`, etc. Subscribes to
/// `Box.watch(key: 'currentUser')` so the value auto-refreshes when any of
/// those flows writes to the box — consumers (e.g. the dashboard greeting)
/// don't need to invalidate manually.
class CurrentUserNotifier extends Notifier<User?> {
  StreamSubscription<BoxEvent>? _sub;

  @override
  User? build() {
    _sub?.cancel();
    if (!Hive.isBoxOpen('userBox')) {
      return null;
    }
    final box = Hive.box<User>('userBox');
    _sub = box.watch(key: 'currentUser').listen((event) {
      state = event.deleted ? null : event.value as User?;
    });
    ref.onDispose(() => _sub?.cancel());
    return box.get('currentUser');
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
);

/// Short display name for greetings: the first whitespace-delimited token of
/// the user's name, or `null` if no user is signed in.
final currentUserFirstNameProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  final name = user?.name.trim();
  if (name == null || name.isEmpty) return null;
  return name.split(RegExp(r'\s+')).first;
});
