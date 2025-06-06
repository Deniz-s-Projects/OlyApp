import 'dart:io';

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/lost_found_service.dart';
import '../utils/user_helpers.dart';
import 'lost_found_detail_page.dart';
import 'package:image_picker/image_picker.dart';

class LostFoundPage extends StatefulWidget {
  final LostFoundService? service;
  const LostFoundPage({super.key, this.service});

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> {
  late final LostFoundService _service;
  final TextEditingController _searchCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  XFile? _imageFile;
  List<LostItem> _items = [];
  String _typeFilter = 'all';
  String _resolvedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? LostFoundService();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _service.fetchItems(
      search: _searchCtrl.text,
      type: _typeFilter == 'all' ? null : _typeFilter,
      resolved: _resolvedFilter == 'all'
          ? null
          : _resolvedFilter == 'true',
    );
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null) setState(() => _imageFile = file);
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
      imageFile: _imageFile != null ? File(_imageFile!.path) : null,
    );
    if (!mounted) return;
    setState(() => _items.add(item));
    _titleCtrl.clear();
    _descCtrl.clear();
    setState(() => _imageFile = null);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search…',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadItems,
                    ),
                  ),
                  onChanged: (_) => _loadItems(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _typeFilter,
                        isExpanded: true,
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => _typeFilter = val);
                          _loadItems();
                        },
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Types')),
                          DropdownMenuItem(value: 'lost', child: Text('Lost')),
                          DropdownMenuItem(value: 'found', child: Text('Found')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _resolvedFilter,
                        isExpanded: true,
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => _resolvedFilter = val);
                          _loadItems();
                        },
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Any Status')),
                          DropdownMenuItem(value: 'false', child: Text('Unresolved')),
                          DropdownMenuItem(value: 'true', child: Text('Resolved')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final changed = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LostFoundDetailPage(
                                item: item,
                                service: _service,
                              ),
                            ),
                          );
                          if (changed == true) _loadItems();
                        },
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
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ],
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 8),
                  Image.file(File(_imageFile!.path), height: 150),
                ],
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _submit, child: const Text('Post')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
