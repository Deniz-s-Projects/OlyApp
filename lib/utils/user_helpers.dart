import 'package:hive/hive.dart';
import '../models/models.dart';

/// Returns the id of the currently logged in user or 0 if unavailable.
int currentUserId() {
  if (!Hive.isBoxOpen('userBox')) return 0;
  final user = Hive.box<User>('userBox').get('currentUser');
  return user?.id ?? 0;
}

/// Returns true if the currently logged in user is an admin.
bool currentUserIsAdmin() {
  if (!Hive.isBoxOpen('userBox')) return false;
  final user = Hive.box<User>('userBox').get('currentUser');
  return user?.isAdmin ?? false;
}
