import '../models/models.dart';

class BulletinService {
  final List<BulletinPost> _posts = [];

  Future<List<BulletinPost>> fetchPosts() async {
    return List.unmodifiable(_posts);
  }

  Future<BulletinPost> addPost(BulletinPost post) async {
    final newPost = BulletinPost(
      id: _posts.length + 1,
      content: post.content,
      date: post.date,
    );
    _posts.add(newPost);
    return newPost;
  }
}
