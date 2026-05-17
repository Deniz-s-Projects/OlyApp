import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/directory_service.dart';

final directoryServiceProvider =
    Provider<DirectoryService>((ref) => DirectoryService());

/// Current search query for the directory page. Setting this re-runs
/// [directoryUsersProvider] for the new value (cached by Riverpod's
/// family-style memoisation on the argument).
class DirectorySearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final directorySearchProvider =
    NotifierProvider<DirectorySearchNotifier, String>(
        DirectorySearchNotifier.new);

/// Loads users for the current [directorySearchProvider] value.
final directoryUsersProvider = FutureProvider<List<User>>(
  (ref) async {
    final search = ref.watch(directorySearchProvider);
    final service = ref.watch(directoryServiceProvider);
    return service.fetchUsers(search: search);
  },
  dependencies: [directoryServiceProvider, directorySearchProvider],
);
