import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/bulletin_service.dart';

class BulletinAdminPage extends StatefulWidget {
  final BulletinService? service;
  const BulletinAdminPage({super.key, this.service});

  @override
  State<BulletinAdminPage> createState() => _BulletinAdminPageState();
}

class _BulletinAdminPageState extends State<BulletinAdminPage> {
  late final BulletinService _service;
  List<BulletinPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BulletinService();
    _load();
  }

  Future<void> _load() async {
    final posts = await _service.fetchPosts();
    setState(() => _posts = posts);
  }

  Future<void> _edit(BulletinPost post) async {
    final ctrl = TextEditingController(text: post.content);
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Post'),
            content: TextField(controller: ctrl),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (result != null && result.isNotEmpty) {
      final updated = BulletinPost(
        id: post.id,
        userId: post.userId,
        content: result,
        date: post.date,
      );
      await _service.updatePost(updated);
      _load();
    }
  }

  Future<void> _delete(int id) async {
    await _service.deletePost(id);
    setState(() => _posts.removeWhere((p) => p.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulletin Posts')),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (ctx, i) {
          final p = _posts[i];
          return ListTile(
            title: Text(p.content),
            subtitle: Text('${p.date.day}/${p.date.month}/${p.date.year}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _edit(p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _delete(p.id!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
