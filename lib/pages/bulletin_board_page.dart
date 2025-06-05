import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bulletin_service.dart';

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

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BulletinService();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await _service.fetchPosts();
    if (!mounted) return;
    setState(() => _posts = posts);
  }

  Future<void> _submit() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final post = await _service.addPost(BulletinPost(content: text));
    if (!mounted) return;
    setState(() => _posts.add(post));
    _textCtrl.clear();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
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
            child: _posts.isEmpty
                ? const Center(child: Text('No posts yet.'))
                : ListView.separated(
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = _posts[i];
                      return ListTile(
                        title: Text(p.content),
                        subtitle: Text(
                          '${p.date.day}/${p.date.month}/${p.date.year}',
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
