import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/wiki_providers.dart';
import '../services/wiki_service.dart';
import '../utils/user_helpers.dart';

class WikiPage extends StatelessWidget {
  final WikiService? service;
  const WikiPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) return const _WikiBody();
    return ProviderScope(
      overrides: [wikiServiceProvider.overrideWithValue(service!)],
      child: const _WikiBody(),
    );
  }
}

class _WikiBody extends ConsumerWidget {
  const _WikiBody();

  bool get _isAdmin => currentUserIsAdmin();

  Future<void> _viewArticle(BuildContext context, WikiArticle article) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(article.title),
        content: SingleChildScrollView(child: Text(article.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrEdit(BuildContext context, WidgetRef ref,
      {WikiArticle? article}) async {
    final titleCtrl = TextEditingController(text: article?.title);
    final contentCtrl = TextEditingController(text: article?.content);
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(article == null ? 'New Article' : 'Edit Article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != true) return;
    final title = titleCtrl.text.trim();
    final content = contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;
    final service = ref.read(wikiServiceProvider);
    if (article == null) {
      await service.addArticle(
        WikiArticle(title: title, content: content, authorId: currentUserId()),
      );
    } else {
      await service.updateArticle(
        WikiArticle(
          id: article.id,
          title: title,
          content: content,
          authorId: article.authorId,
          createdAt: article.createdAt,
        ),
      );
    }
    ref.invalidate(wikiArticlesProvider);
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, WikiArticle article) async {
    if (article.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text(
          'Are you sure you want to delete this article?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(wikiServiceProvider).deleteArticle(article.id!);
    ref.invalidate(wikiArticlesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final articles = ref.watch(wikiArticlesProvider).valueOrNull ??
        const <WikiArticle>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiki'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _addOrEdit(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(wikiArticlesProvider),
        child: ListView.separated(
          itemCount: articles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final article = articles[i];
            return ListTile(
              title: Text(article.title),
              onTap: () => _viewArticle(context, article),
              trailing: _isAdmin
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _addOrEdit(context, ref, article: article),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _delete(context, ref, article),
                        ),
                      ],
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
