import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/map_pin.dart';
import '../services/map_service.dart';

final mapServiceProvider = Provider<MapService>((ref) => MapService());

final mapPinsProvider = FutureProvider<List<MapPin>>(
  (ref) async {
    final service = ref.watch(mapServiceProvider);
    return service.fetchPins();
  },
  dependencies: [mapServiceProvider],
);
