import 'package:test/test.dart';
import 'package:oly_app/services/bulletin_service.dart';
import 'package:oly_app/models/models.dart';

void main() {
  group('BulletinService', () {
    test('addPost assigns incrementing ids', () async {
      final service = BulletinService();
      final first = await service.addPost(BulletinPost(content: 'a'));
      final second = await service.addPost(BulletinPost(content: 'b'));

      expect(first.id, 1);
      expect(second.id, 2);
    });

    test('fetchPosts returns unmodifiable list', () async {
      final service = BulletinService();
      await service.addPost(BulletinPost(content: 'a'));
      final posts = await service.fetchPosts();

      expect(
        () => posts.add(BulletinPost(content: 'b')),
        throwsUnsupportedError,
      );
    });

    test(
      'addComment stores comments per post and lists are immutable',
      () async {
        final service = BulletinService();
        final post1 = await service.addPost(BulletinPost(content: 'p1'));
        final post2 = await service.addPost(BulletinPost(content: 'p2'));

        await service.addComment(
          BulletinComment(postId: post1.id!, content: 'c1'),
        );
        await service.addComment(
          BulletinComment(postId: post2.id!, content: 'c2'),
        );

        final comments1 = await service.fetchComments(post1.id!);
        final comments2 = await service.fetchComments(post2.id!);

        expect(comments1.map((c) => c.content), ['c1']);
        expect(comments2.map((c) => c.content), ['c2']);
        expect(
          () => comments1.add(BulletinComment(postId: post1.id!, content: 'x')),
          throwsUnsupportedError,
        );

        await service.addComment(
          BulletinComment(postId: post2.id!, content: 'c3'),
        );
        final comments2Updated = await service.fetchComments(post2.id!);

        // ensure lists are isolated and previous list is unchanged
        expect(comments1, hasLength(1));
        expect(comments2Updated, hasLength(2));
      },
    );
  });
}
