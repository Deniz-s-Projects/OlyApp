import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/tutoring_providers.dart';
import '../services/tutoring_service.dart';
import 'post_tutoring_page.dart';

class TutoringPage extends StatelessWidget {
  final TutoringService? service;
  const TutoringPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _TutoringBody();
    }
    return ProviderScope(
      overrides: [tutoringServiceProvider.overrideWithValue(service!)],
      child: const _TutoringBody(),
    );
  }
}

class _TutoringBody extends ConsumerWidget {
  const _TutoringBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts =
        ref.watch(tutoringPostsProvider).valueOrNull ?? const <TutoringPost>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Tutoring')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(tutoringPostsProvider),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (_, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post.subject),
              subtitle: Text(post.description),
              trailing: Text(post.isOffering ? 'Offering' : 'Seeking'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostTutoringPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
