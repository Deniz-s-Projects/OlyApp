import '../models/models.dart';
import 'api_service.dart';

class BulletinService extends ApiService {
  BulletinService({super.client});

  Future<List<BulletinPost>> fetchPosts() async {
    return get('/bulletin', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => BulletinPost.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<BulletinPost> addPost(BulletinPost bulletin) async {
    return post(
      '/bulletin',
      bulletin.toJson(),
      (json) => BulletinPost.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<List<BulletinComment>> fetchComments(int postId) async {
    return get('/bulletin/$postId/comments', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => BulletinComment.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<BulletinComment> addComment(BulletinComment comment) async {
    return post(
      '/bulletin/${comment.postId}/comments',
      comment.toJson(),
      (json) => BulletinComment.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<BulletinPost> updatePost(BulletinPost post) async {
    if (post.id == null) throw ArgumentError('id required');
    return put(
      '/bulletin/${post.id}',
      post.toJson(),
      (json) => BulletinPost.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deletePost(int id) async {
    await delete('/bulletin/$id', (_) => null);
  }
}
