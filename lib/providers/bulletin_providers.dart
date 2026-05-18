import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/bulletin_service.dart';

final bulletinServiceProvider =
    Provider<BulletinService>((ref) => BulletinService());

final bulletinPostsProvider = FutureProvider<List<BulletinPost>>(
  (ref) async {
    ref.keepAlive();
    final service = ref.watch(bulletinServiceProvider);
    return service.fetchPosts();
  },
  dependencies: [bulletinServiceProvider],
);

/// Comments per post. Keyed by post id; each entry is the latest fetch.
/// Invalidate the family member to refresh comments for that post.
final bulletinCommentsProvider =
    FutureProvider.family<List<BulletinComment>, int>(
  (ref, postId) async {
    final service = ref.watch(bulletinServiceProvider);
    return service.fetchComments(postId);
  },
  dependencies: [bulletinServiceProvider],
);
