import 'package:flutter/material.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/bulletin_providers.dart';
import '../services/bulletin_service.dart';
import '../utils/user_helpers.dart';
import '../widgets/empty_state.dart';

/// Bulletin board surface. Designed to be hosted as a [MainPage] destination
/// (the bulletin tab) — it intentionally does **not** render its own
/// [AppBar] because [MainPage] already provides one. If you ever need to
/// push this page directly (deep link, standalone screen, etc.), wrap it
/// in a [Scaffold] + [AppBar] of your own.
class BulletinBoardPage extends ConsumerStatefulWidget {
  final BulletinService? service;
  const BulletinBoardPage({super.key, this.service});

  @override
  ConsumerState<BulletinBoardPage> createState() => _BulletinBoardPageState();
}

class _BulletinBoardPageState extends ConsumerState<BulletinBoardPage> {
  final TextEditingController _textCtrl = TextEditingController();
  List<BulletinPost> _posts = [];
  final Map<int, List<BulletinComment>> _comments = {};
  final Map<int, TextEditingController> _commentCtrls = {};

  BulletinService _resolveService() {
    final BulletinService service =
        widget.service ?? ref.read(bulletinServiceProvider);
    return service;
  }

  String _authorName(String userId) {
    final me = currentUserId();
    return userId == me ? 'You' : 'User $userId';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPosts());
  }

  Future<void> _loadPosts() async {
    final service = _resolveService();
    final posts = await service.fetchPosts();
    if (!mounted) return;
    final commentEntries = <int, List<BulletinComment>>{};
    for (final p in posts) {
      if (p.id != null) {
        commentEntries[p.id!] = await service.fetchComments(p.id!);
      }
    }
    setState(() {
      _posts = posts;
      _comments
        ..clear()
        ..addAll(commentEntries);
    });
  }

  Future<void> _submit() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final post = await _resolveService().addPost(
      BulletinPost(userId: currentUserId(), content: text),
    );
    if (!mounted) return;
    setState(() {
      _posts.add(post);
      if (post.id != null) _comments[post.id!] = [];
    });
    _textCtrl.clear();
  }

  Future<void> _submitComment(int postId) async {
    final ctrl = _commentCtrls[postId];
    if (ctrl == null) return;
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    final comment = await _resolveService().addComment(
      BulletinComment(
        postId: postId,
        userId: currentUserId(),
        content: text,
      ),
    );
    if (!mounted) return;
    setState(() => _comments.putIfAbsent(postId, () => []).add(comment));
    ctrl.clear();
  }

  Future<void> _editPost(BulletinPost post) async {
    final ctrl = TextEditingController(text: post.content);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit post'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final updated = await _resolveService().updatePost(
        BulletinPost(
          id: post.id,
          userId: post.userId,
          content: result,
          date: post.date,
        ),
      );
      if (!mounted) return;
      setState(() {
        final idx = _posts.indexWhere((p) => p.id == post.id);
        if (idx != -1) _posts[idx] = updated;
      });
    }
  }

  Future<void> _deletePost(int id) async {
    await _resolveService().deletePost(id);
    if (!mounted) return;
    setState(() {
      _posts.removeWhere((p) => p.id == id);
      _comments.remove(id);
    });
  }

  Future<void> _editComment(int postId, BulletinComment comment) async {
    final ctrl = TextEditingController(text: comment.content);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit comment'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty || comment.id == null) return;
    try {
      final updated = await _resolveService().updateComment(
        BulletinComment(
          id: comment.id,
          postId: postId,
          userId: comment.userId,
          content: result,
          date: comment.date,
        ),
      );
      if (!mounted) return;
      setState(() {
        final list = _comments[postId];
        final idx = list?.indexWhere((c) => c.id == comment.id) ?? -1;
        if (idx != -1) list![idx] = updated;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update comment: $e')),
      );
    }
  }

  Future<void> _deleteComment(int postId, int id) async {
    try {
      await _resolveService().deleteComment(postId, id);
      if (!mounted) return;
      setState(() {
        _comments[postId]?.removeWhere((c) => c.id == id);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $e')),
      );
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    for (final c in _commentCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child:
                _posts.isEmpty
                    ? EmptyState(
                      icon: Icons.campaign_outlined,
                      title: AppLocalizations.of(context).emptyBulletin,
                      subtitle:
                          AppLocalizations.of(context).emptyBulletinSubtitle,
                    )
                    : ListView.separated(
                      itemCount: _posts.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final p = _posts[i];
                        final comments = _comments[p.id] ?? const [];
                        final ctrl = _commentCtrls.putIfAbsent(
                          p.id!,
                          () => TextEditingController(),
                        );
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.content),
                                        Text(
                                          _authorName(p.userId),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          '${p.date.day}/${p.date.month}/${p.date.year}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    key: ValueKey('editPost_${p.id}'),
                                    icon: const Icon(Icons.edit),
                                    tooltip: AppLocalizations.of(context)
                                        .a11yEditPost,
                                    onPressed: () => _editPost(p),
                                  ),
                                  IconButton(
                                    key: ValueKey('deletePost_${p.id}'),
                                    icon: const Icon(Icons.delete),
                                    tooltip: AppLocalizations.of(context)
                                        .a11yDeletePost,
                                    onPressed: () => _deletePost(p.id!),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              for (final c in comments)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${_authorName(c.userId)}: ${c.content}',
                                        ),
                                      ),
                                      IconButton(
                                        key: ValueKey('editComment_${p.id}_${c.id}'),
                                        icon: const Icon(Icons.edit, size: 18),
                                        tooltip: AppLocalizations.of(context)
                                            .a11yEditComment,
                                        onPressed: () => _editComment(p.id!, c),
                                      ),
                                      IconButton(
                                        key: ValueKey('deleteComment_${p.id}_${c.id}'),
                                        icon: const Icon(Icons.delete, size: 18),
                                        tooltip: AppLocalizations.of(context)
                                            .a11yDeleteComment,
                                        onPressed: () => _deleteComment(p.id!, c.id!),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      key: ValueKey('commentField_${p.id}'),
                                      controller: ctrl,
                                      decoration: const InputDecoration(
                                        hintText: 'Add comment...',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    key: ValueKey('sendComment_${p.id}'),
                                    icon: const Icon(Icons.send),
                                    tooltip: AppLocalizations.of(context)
                                        .a11ySendComment,
                                    onPressed: () => _submitComment(p.id!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Write a post...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  tooltip: AppLocalizations.of(context).a11ySendMessage,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
