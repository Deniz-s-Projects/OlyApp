import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/service_listings_providers.dart';
import '../services/service_list_service.dart';
import '../utils/user_helpers.dart';

class PostServiceListingPage extends ConsumerStatefulWidget {
  final ServiceListing? listing;
  final ServiceListService? service;

  const PostServiceListingPage({super.key, this.listing, this.service});

  @override
  ConsumerState<PostServiceListingPage> createState() =>
      _PostServiceListingPageState();
}

class _PostServiceListingPageState
    extends ConsumerState<PostServiceListingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _contactCtrl;
  bool _submitting = false;

  bool get _editing => widget.listing != null;

  ServiceListService _resolveService() {
    final ServiceListService service =
        widget.service ?? ref.read(serviceListServiceProvider);
    return service;
  }

  @override
  void initState() {
    super.initState();
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
      final service = _resolveService();
      if (editing) {
        await service.updateListing(listing);
      } else {
        await service.addListing(listing);
      }
      if (mounted) {
        ref.invalidate(serviceListingsProvider);
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text(
          'Are you sure you want to delete this listing?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _resolveService().deleteListing(id);
    if (mounted) {
      ref.invalidate(serviceListingsProvider);
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
