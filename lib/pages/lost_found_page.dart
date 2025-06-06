import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/lost_found_service.dart';
import '../utils/user_helpers.dart';

class LostFoundPage extends StatefulWidget {
  final LostFoundService? service;
  const LostFoundPage({super.key, this.service});

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> {
  late final LostFoundService _service;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<LostItem> _items = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? LostFoundService();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _service.fetchItems();
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final item = await _service.createItem(
      LostItem(
        ownerId: currentUserId(),
        title: title,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _items.add(item));
    _titleCtrl.clear();
    _descCtrl.clear();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No posts yet.'))
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      return ListTile(
                        title: Text(item.title),
                        subtitle: item.description != null
                            ? Text(item.description!)
                            : null,
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
