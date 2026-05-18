import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

/// The user currently signed in, or `null` if no session is active.
/// Sourced from the Hive `userBox` populated by the login flow in
/// `lib/main.dart`. Invalidate after login/logout for the UI to refresh.
final currentUserProvider = Provider<User?>((ref) {
  if (!Hive.isBoxOpen('userBox')) return null;
  final box = Hive.box<User>('userBox');
  return box.get('currentUser');
});

/// Short display name for greetings: the first whitespace-delimited token of
/// the user's name, or `null` if no user is signed in.
final currentUserFirstNameProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  final name = user?.name.trim();
  if (name == null || name.isEmpty) return null;
  return name.split(RegExp(r'\s+')).first;
});
