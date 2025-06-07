import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/wiki_service.dart';
import '../utils/user_helpers.dart';

class WikiPage extends StatefulWidget {
  final WikiService? service;
  const WikiPage({super.key, this.service});

  @override
  State<WikiPage> createState() => _WikiPageState();
}

class _WikiPageState extends State<WikiPage> {
  late final WikiService _service;
  List<WikiArticle> _articles = [];

  bool get _isAdmin => currentUserIsAdmin();

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WikiService();
    _load();
  }

  Future<void> _load() async {
    final articles = await _service.fetchArticles();
    if (!mounted) return;
    setState(() => _articles = articles);
  }

  Future<void> _viewArticle(WikiArticle article) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(article.title),
        content: SingleChildScrollView(child: Text(article.content)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _addOrEdit({WikiArticle? article}) async {
    final titleCtrl = TextEditingController(text: article?.title);
    final contentCtrl = TextEditingController(text: article?.content);
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(article == null ? 'New Article' : 'Edit Article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Content'), maxLines: 5),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (result != true) return;
    final title = titleCtrl.text.trim();
    final content = contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;
    if (article == null) {
      final created = await _service.addArticle(
        WikiArticle(title: title, content: content, authorId: currentUserId()),
      );
      if (!mounted) return;
      setState(() => _articles.add(created));
    } else {
      final updated = await _service.updateArticle(
        WikiArticle(
          id: article.id,
          title: title,
          content: content,
          authorId: article.authorId,
          createdAt: article.createdAt,
        ),
      );
      if (!mounted) return;
      setState(() {
        final idx = _articles.indexWhere((a) => a.id == updated.id);
        if (idx != -1) _articles[idx] = updated;
      });
    }
  }

  Future<void> _delete(WikiArticle article) async {
    if (article.id == null) return;
    await _service.deleteArticle(article.id!);
    if (!mounted) return;
    setState(() => _articles.removeWhere((a) => a.id == article.id));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiki'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _addOrEdit(),
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          itemCount: _articles.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final article = _articles[i];
            return ListTile(
              title: Text(article.title),
              onTap: () => _viewArticle(article),
              trailing: _isAdmin
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _addOrEdit(article: article),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _delete(article),
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
