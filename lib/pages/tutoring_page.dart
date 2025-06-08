import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/tutoring_service.dart';
import 'post_tutoring_page.dart';

class TutoringPage extends StatefulWidget {
  final TutoringService? service;
  const TutoringPage({super.key, this.service});

  @override
  State<TutoringPage> createState() => _TutoringPageState();
}

class _TutoringPageState extends State<TutoringPage> {
  late final TutoringService _service;
  List<TutoringPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TutoringService();
    _load();
  }

  Future<void> _load() async {
    final posts = await _service.fetchPosts();
    if (mounted) setState(() => _posts = posts);
  }

  Future<void> _openForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PostTutoringPage(service: _service)),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutoring')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (_, index) {
            final post = _posts[index];
            return ListTile(
              title: Text(post.subject),
              subtitle: Text(post.description),
              trailing: Text(post.isOffering ? 'Offering' : 'Seeking'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
