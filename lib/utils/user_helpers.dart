import 'package:hive/hive.dart';
import '../models/models.dart';

/// Returns the id of the currently logged in user or empty string if unavailable.
String currentUserId() {
  if (!Hive.isBoxOpen('userBox')) return '';
  final user = Hive.box<User>('userBox').get('currentUser');
  return user?.id ?? '';
}

/// Returns true if the currently logged in user is an admin.
bool currentUserIsAdmin() {
  if (!Hive.isBoxOpen('userBox')) return false;
  final user = Hive.box<User>('userBox').get('currentUser');
  return user?.isAdmin ?? false;
}
