import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/job_post_service.dart';
import '../job_posts/post_job_page.dart';

class JobPostsPage extends StatefulWidget {
  final JobPostService? service;
  const JobPostsPage({super.key, this.service});

  @override
  State<JobPostsPage> createState() => _JobPostsPageState();
}

class _JobPostsPageState extends State<JobPostsPage> {
  late final JobPostService _service;
  List<JobPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? JobPostService();
    _load();
  }

  Future<void> _load() async {
    final posts = await _service.fetchPosts();
    if (mounted) setState(() => _posts = posts);
  }

  Future<void> _openForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PostJobPage(service: _service)),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Posts')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          itemCount: _posts.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final post = _posts[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.description),
              trailing: post.pay != null ? Text(post.pay!) : null,
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
