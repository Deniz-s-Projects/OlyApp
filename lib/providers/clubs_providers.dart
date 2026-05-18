import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/club_service.dart';

final clubServiceProvider =
    Provider<ClubService>((ref) => ClubService());

final clubsProvider = FutureProvider<List<Club>>(
  (ref) async {
    ref.keepAlive();
    final service = ref.watch(clubServiceProvider);
    return service.fetchClubs();
  },
  dependencies: [clubServiceProvider],
);
