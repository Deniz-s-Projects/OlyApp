import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/service_list_service.dart';
import '../utils/user_helpers.dart';

class PostServiceListingPage extends StatefulWidget {
  final ServiceListing? listing;
  final ServiceListService? service;

  const PostServiceListingPage({super.key, this.listing, this.service});

  @override
  State<PostServiceListingPage> createState() => _PostServiceListingPageState();
}

class _PostServiceListingPageState extends State<PostServiceListingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _contactCtrl;
  late final ServiceListService _service;
  bool _submitting = false;

  bool get _editing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ServiceListService();
    final l = widget.listing;
    _titleCtrl = TextEditingController(text: l?.title ?? '');
    _descCtrl = TextEditingController(text: l?.description ?? '');
    _contactCtrl = TextEditingController(text: l?.contact ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final editing = _editing;
      final listing = ServiceListing(
        id: editing ? widget.listing!.id : null,
        userId: editing ? widget.listing!.userId : currentUserId(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        contact: _contactCtrl.text.trim().isEmpty
            ? null
            : _contactCtrl.text.trim(),
      );
      if (editing) {
        await _service.updateListing(listing);
      } else {
        await _service.addListing(listing);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editing ? 'Listing updated!' : 'Listing posted!'),
          ),
        );
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

  Future<void> _delete() async {
    final id = widget.listing?.id;
    if (id == null) return;
    await _service.deleteListing(id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listing deleted')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Listing' : 'New Listing')),
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
                controller: _contactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact info (optional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Text(
                  _submitting
                      ? (_editing ? 'Updating…' : 'Posting…')
                      : _editing
                      ? 'Update'
                      : 'Post',
                ),
              ),
              if (_editing) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _submitting ? null : _delete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
