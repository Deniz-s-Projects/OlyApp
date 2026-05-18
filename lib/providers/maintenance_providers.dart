import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/maintenance_service.dart';

/// Single source of truth for the [MaintenanceService] instance.
/// Overridden in tests via [ProviderScope.overrides].
final maintenanceServiceProvider =
    Provider<MaintenanceService>((ref) => MaintenanceService());

/// Loads the user's maintenance tickets. Refresh by invalidating the provider
/// (e.g. `ref.invalidate(maintenanceRequestsProvider)`).
///
/// `dependencies: [maintenanceServiceProvider]` lets nested `ProviderScope`
/// overrides of [maintenanceServiceProvider] flow through correctly.
final maintenanceRequestsProvider = FutureProvider<List<MaintenanceRequest>>(
  (ref) async {
    ref.keepAlive();
    final service = ref.watch(maintenanceServiceProvider);
    return service.fetchRequests();
  },
  dependencies: [maintenanceServiceProvider],
);
