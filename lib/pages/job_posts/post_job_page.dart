import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/job_post_service.dart';
import '../../utils/user_helpers.dart';

class PostJobPage extends StatefulWidget {
  final JobPostService? service;
  const PostJobPage({super.key, this.service});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _payCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  bool _submitting = false;
  late final JobPostService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? JobPostService();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _payCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final post = JobPost(
        ownerId: currentUserId(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        pay: _payCtrl.text.trim().isEmpty ? null : _payCtrl.text.trim(),
        contact: _contactCtrl.text.trim().isEmpty
            ? null
            : _contactCtrl.text.trim(),
      );
      await _service.createPost(post);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Posted!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Job Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _payCtrl,
                decoration: const InputDecoration(labelText: 'Pay (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact info (optional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Posting…' : 'Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
