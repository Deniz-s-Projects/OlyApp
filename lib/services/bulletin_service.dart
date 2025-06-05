import '../models/models.dart';

class BulletinService {
  final List<BulletinPost> _posts = [];
  final Map<int, List<BulletinComment>> _comments = {};

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
    _comments[newPost.id!] = [];
    return newPost;
  }

  Future<List<BulletinComment>> fetchComments(int postId) async {
    return List.unmodifiable(_comments[postId] ?? const []);
  }

  Future<BulletinComment> addComment(BulletinComment comment) async {
    final list = _comments.putIfAbsent(comment.postId, () => []);
    final newComment = BulletinComment(
      id: list.length + 1,
      postId: comment.postId,
      content: comment.content,
      date: comment.date,
    );
    list.add(newComment);
    return newComment;
  }
}
