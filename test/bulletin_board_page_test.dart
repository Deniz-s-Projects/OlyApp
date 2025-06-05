import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/pages/bulletin_board_page.dart';
import 'package:oly_app/services/bulletin_service.dart';
import 'package:oly_app/models/models.dart';

class FakeBulletinService extends BulletinService {
  final List<BulletinPost> posts;
  final Map<int, List<BulletinComment>> comments;
  FakeBulletinService(this.posts, this.comments);

  @override
  Future<List<BulletinPost>> fetchPosts() async => posts;

  @override
  Future<BulletinPost> addPost(BulletinPost post) async {
    final newPost = BulletinPost(
      id: posts.length + 1,
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
      content: comment.content,
      date: comment.date,
    );
    list.add(saved);
    return saved;
  }
}

void main() {
  testWidgets('Existing posts are shown', (tester) async {
    final service = FakeBulletinService(
      [BulletinPost(id: 1, content: 'Hello', date: DateTime.now())],
      {
        1: [BulletinComment(postId: 1, content: 'Nice', date: DateTime.now())],
      },
    );
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Nice'), findsOneWidget);
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
      [BulletinPost(id: 1, content: 'Post', date: DateTime.now())],
      {1: []},
    );
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('commentField_1')), 'Hi');
    await tester.tap(find.byKey(const ValueKey('sendComment_1')));
    await tester.pumpAndSettle();

    expect(find.text('Hi'), findsWidgets);
  });
}
