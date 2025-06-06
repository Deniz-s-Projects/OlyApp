import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/pages/bulletin_board_page.dart';
import 'package:oly_app/services/bulletin_service.dart';
import 'package:oly_app/models/models.dart';

class FakeBulletinService extends BulletinService {
  final List<BulletinPost> posts;
  final Map<int, List<BulletinComment>> comments;
  BulletinPost? updated;
  int? deletedId;
  FakeBulletinService(this.posts, this.comments);

  @override
  Future<List<BulletinPost>> fetchPosts() async => posts;

  @override
  Future<BulletinPost> addPost(BulletinPost post) async {
    final newPost = BulletinPost(
      id: posts.length + 1,
      userId: post.userId,
      content: post.content,
      date: post.date,
    );
    posts.add(newPost);
    comments[newPost.id!] = [];
    return newPost;
  }

  @override
  Future<List<BulletinComment>> fetchComments(int postId) async =>
      comments[postId] ?? [];

  @override
  Future<BulletinComment> addComment(BulletinComment comment) async {
    final list = comments.putIfAbsent(comment.postId, () => []);
    final saved = BulletinComment(
      id: list.length + 1,
      postId: comment.postId,
      userId: comment.userId,
      content: comment.content,
      date: comment.date,
    );
    list.add(saved);
    return saved;
  }

  @override
  Future<BulletinPost> updatePost(BulletinPost post) async {
    updated = post;
    final idx = posts.indexWhere((p) => p.id == post.id);
    if (idx != -1) posts[idx] = post;
    return post;
  }

  @override
  Future<void> deletePost(int id) async {
    deletedId = id;
    posts.removeWhere((p) => p.id == id);
    comments.remove(id);
  }
}

void main() {
  testWidgets('Existing posts are shown', (tester) async {
    final service = FakeBulletinService(
      [BulletinPost(id: 1, userId: '1', content: 'Hello', date: DateTime.now())],
      {
        1: [BulletinComment(postId: 1, userId: '2', content: 'Nice', date: DateTime.now())],
      },
    );
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.textContaining('Nice'), findsOneWidget);
  });

  testWidgets('Submitting adds new post', (tester) async {
    final service = FakeBulletinService([], {});
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'New Post');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('New Post'), findsWidgets);
  });

  testWidgets('Submitting comment displays it', (tester) async {
    final service = FakeBulletinService(
      [BulletinPost(id: 1, userId: '1', content: 'Post', date: DateTime.now())],
      {1: []},
    );
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('commentField_1')), 'Hi');
    await tester.tap(find.byKey(const ValueKey('sendComment_1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Hi'), findsWidgets);
  });

  testWidgets('Edit icon updates post', (tester) async {
    final service = FakeBulletinService(
      [BulletinPost(id: 1, userId: '1', content: 'Old', date: DateTime.now())],
      {1: []},
    );
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('editPost_1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'New');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(service.updated?.content, 'New');
  });

  testWidgets('Delete icon removes post', (tester) async {
    final service = FakeBulletinService(
      [BulletinPost(id: 1, userId: '1', content: 'Bye', date: DateTime.now())],
      {1: []},
    );
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('deletePost_1')));
    await tester.pump();

    expect(service.deletedId, 1);
  });
}
