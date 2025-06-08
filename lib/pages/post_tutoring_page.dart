import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/tutoring_service.dart';
import '../utils/user_helpers.dart';

class PostTutoringPage extends StatefulWidget {
  final TutoringService? service;
  const PostTutoringPage({super.key, this.service});

  @override
  State<PostTutoringPage> createState() => _PostTutoringPageState();
}

class _PostTutoringPageState extends State<PostTutoringPage> {
  final _formKey = GlobalKey<FormState>();
  late final TutoringService _service;
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isOffering = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TutoringService();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final post = TutoringPost(
        userId: currentUserId(),
        subject: _subjectCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        isOffering: _isOffering,
        contactUserId: currentUserId(),
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
      appBar: AppBar(title: const Text('New Tutoring Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(labelText: 'Subject'),
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
              SwitchListTile(
                title: const Text('Offering tutoring'),
                value: _isOffering,
                onChanged: (v) => setState(() => _isOffering = v),
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
