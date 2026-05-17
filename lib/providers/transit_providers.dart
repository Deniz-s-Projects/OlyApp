import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/transit_service.dart';

final transitServiceProvider =
    Provider<TransitService>((ref) => TransitService());

/// User's pinned stops, persisted via the service. Search results and
/// per-stop departures stay as local widget state (they change too often
/// to benefit from caching).
final pinnedStopsProvider = FutureProvider<List<TransitStop>>(
  (ref) async {
    final service = ref.watch(transitServiceProvider);
    return service.loadPinnedStops();
  },
  dependencies: [transitServiceProvider],
);
