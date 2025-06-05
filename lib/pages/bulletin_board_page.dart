import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bulletin_service.dart';
import '../utils/user_helpers.dart';

class BulletinBoardPage extends StatefulWidget {
  final BulletinService? service;
  const BulletinBoardPage({super.key, this.service});

  @override
  State<BulletinBoardPage> createState() => _BulletinBoardPageState();
}

class _BulletinBoardPageState extends State<BulletinBoardPage> {
  late final BulletinService _service;
  final TextEditingController _textCtrl = TextEditingController();
  List<BulletinPost> _posts = [];
  final Map<int, List<BulletinComment>> _comments = {};
  final Map<int, TextEditingController> _commentCtrls = {};

  String _authorName(int userId) {
    final me = currentUserId();
    return userId == me ? 'You' : 'User $userId';
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BulletinService();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await _service.fetchPosts();
    if (!mounted) return;
    final commentEntries = <int, List<BulletinComment>>{};
    for (final p in posts) {
      if (p.id != null) {
        commentEntries[p.id!] = await _service.fetchComments(p.id!);
      }
    }
    setState(() {
      _posts = posts;
      _comments.addAll(commentEntries);
    });
  }

  Future<void> _submit() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final post = await _service.addPost(
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
    final comment = await _service.addComment(
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
      final updated = await _service.updatePost(
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
    await _service.deletePost(id);
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
    if (result != null && result.isNotEmpty) {
      setState(() {
        final list = _comments[postId];
        final idx = list?.indexWhere((c) => c.id == comment.id) ?? -1;
        if (idx != -1) {
          list![idx] = BulletinComment(
            id: comment.id,
            postId: postId,
            userId: comment.userId,
            content: result,
            date: comment.date,
          );
        }
      });
    }
  }

  void _deleteComment(int postId, int id) {
    setState(() {
      _comments[postId]?.removeWhere((c) => c.id == id);
    });
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulletin Board'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _posts.isEmpty
                    ? const Center(child: Text('No posts yet.'))
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
                                    onPressed: () => _editPost(p),
                                  ),
                                  IconButton(
                                    key: ValueKey('deletePost_${p.id}'),
                                    icon: const Icon(Icons.delete),
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
                                        onPressed: () => _editComment(p.id!, c),
                                      ),
                                      IconButton(
                                        key: ValueKey('deleteComment_${p.id}_${c.id}'),
                                        icon: const Icon(Icons.delete, size: 18),
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
                IconButton(icon: const Icon(Icons.send), onPressed: _submit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
