import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/pages/bulletin_board_page.dart';
import 'package:oly_app/services/bulletin_service.dart';
import 'package:oly_app/models/models.dart';

class FakeBulletinService extends BulletinService {
  final List<BulletinPost> posts;
  FakeBulletinService(this.posts);
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
    return newPost;
  }
}

void main() {
  testWidgets('Existing posts are shown', (tester) async {
    final service = FakeBulletinService([
      BulletinPost(id: 1, content: 'Hello', date: DateTime.now()),
    ]);
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('Submitting adds new post', (tester) async {
    final service = FakeBulletinService([]);
    await tester.pumpWidget(
      MaterialApp(home: BulletinBoardPage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'New Post');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('New Post'), findsWidgets);
  });
}
