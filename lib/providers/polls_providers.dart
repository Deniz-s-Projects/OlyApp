import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/poll_service.dart';

final pollServiceProvider = Provider<PollService>((ref) => PollService());

final pollsProvider = FutureProvider<List<Poll>>(
  (ref) async {
    final service = ref.watch(pollServiceProvider);
    return service.fetchPolls();
  },
  dependencies: [pollServiceProvider],
);
