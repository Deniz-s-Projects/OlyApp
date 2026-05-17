import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/pages/bulletin_board_page.dart';
import 'package:oly_app/services/bulletin_service.dart';
import 'package:oly_app/models/models.dart';

class FakeBulletinService extends BulletinService {
  final List<BulletinPost> posts;
  final Map<int, List<BulletinComment>> comments;
  BulletinPost? updated;
  BulletinComment? updatedComment;
  int? deletedId;
  ({int postId, int id})? deletedComment;
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

  @override
  Future<BulletinComment> updateComment(BulletinComment comment) async {
    updatedComment = comment;
    final list = comments[comment.postId];
    final idx = list?.indexWhere((c) => c.id == comment.id) ?? -1;
    if (idx != -1) list![idx] = comment;
    return comment;
  }

  @override
  Future<void> deleteComment(int postId, int commentId) async {
    deletedComment = (postId: postId, id: commentId);
    comments[postId]?.removeWhere((c) => c.id == commentId);
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
      ProviderScope(
        child: MaterialApp(home: BulletinBoardPage(service: service)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.textContaining('Nice'), findsOneWidget);
  });

  testWidgets('Submitting adds new post', (tester) async {
    final service = FakeBulletinService([], {});
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: BulletinBoardPage(service: service)),
      ),
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
      ProviderScope(
        child: MaterialApp(home: BulletinBoardPage(service: service)),
      ),
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
      ProviderScope(
        child: MaterialApp(home: BulletinBoardPage(service: service)),
      ),
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
      ProviderScope(
        child: MaterialApp(home: BulletinBoardPage(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('deletePost_1')));
    await tester.pump();

    expect(service.deletedId, 1);
  });

  testWidgets('Edit comment icon calls updateComment', (tester) async {
    final service = FakeBulletinService(
      [BulletinPost(id: 1, userId: '1', content: 'p', date: DateTime.now())],
      {
        1: [
          BulletinComment(
            id: 7,
            postId: 1,
            userId: '2',
            content: 'old',
            date: DateTime.now(),
          ),
        ],
      },
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: BulletinBoardPage(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('editComment_1_7')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'new');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(service.updatedComment?.content, 'new');
    expect(service.updatedComment?.id, 7);
  });

  testWidgets('Delete comment icon calls deleteComment', (tester) async {
    final service = FakeBulletinService(
      [BulletinPost(id: 1, userId: '1', content: 'p', date: DateTime.now())],
      {
        1: [
          BulletinComment(
            id: 9,
            postId: 1,
            userId: '2',
            content: 'c',
            date: DateTime.now(),
          ),
        ],
      },
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: BulletinBoardPage(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('deleteComment_1_9')));
    await tester.pumpAndSettle();

    expect(service.deletedComment?.postId, 1);
    expect(service.deletedComment?.id, 9);
  });
}
