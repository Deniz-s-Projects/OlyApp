import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/tutoring_service.dart';

final tutoringServiceProvider =
    Provider<TutoringService>((ref) => TutoringService());

final tutoringPostsProvider = FutureProvider<List<TutoringPost>>(
  (ref) async {
    final service = ref.watch(tutoringServiceProvider);
    return service.fetchPosts();
  },
  dependencies: [tutoringServiceProvider],
);
