import 'dart:io';

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/lost_found_service.dart';
import '../utils/user_helpers.dart';

class LostFoundDetailPage extends StatefulWidget {
  final LostItem item;
  final LostFoundService? service;
  const LostFoundDetailPage({super.key, required this.item, this.service});

  @override
  State<LostFoundDetailPage> createState() => _LostFoundDetailPageState();
}

class _LostFoundDetailPageState extends State<LostFoundDetailPage> {
  late LostItem _item;
  late final LostFoundService _service;
  final _messageCtrl = TextEditingController();
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _service = widget.service ?? LostFoundService();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_item.id == null) return;
    try {
      final msgs = await _service.fetchMessages(_item.id!);
      if (mounted) setState(() => _messages = msgs);
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _item.id == null) return;
    final msg = Message(
      requestId: int.tryParse(_item.id!) ?? 0,
      senderId: currentUserId(),
      content: text,
    );
    try {
      final saved = await _service.sendMessage(_item.id!, msg);
      if (mounted) {
        setState(() => _messages.add(saved));
        _messageCtrl.clear();
      }
    } catch (_) {}
  }

  Future<void> _resolveItem() async {
    if (_item.id == null) return;
    await _service.resolveItem(_item.id!);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteItem() async {
    if (_item.id == null) return;
    await _service.deleteItem(_item.id!);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _editItem() async {
    final titleCtrl = TextEditingController(text: _item.title);
    final descCtrl = TextEditingController(text: _item.description ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true && _item.id != null) {
      final updated = await _service.updateItem(
        LostItem(
          id: _item.id,
          ownerId: _item.ownerId,
          title: titleCtrl.text.trim(),
          description: descCtrl.text.trim().isEmpty
              ? null
              : descCtrl.text.trim(),
          imageUrl: _item.imageUrl,
          type: _item.type,
          resolved: _item.resolved,
          createdAt: _item.createdAt,
        ),
      );
      if (mounted) setState(() => _item = updated);
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isOwner = _item.ownerId == currentUserId();
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.title),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        actions: [
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'resolve') {
                  _resolveItem();
                } else if (val == 'edit') {
                  _editItem();
                } else if (val == 'delete') {
                  _deleteItem();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'resolve', child: Text('Resolve')),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          _item.imageUrl != null
              ? Image.network(
                  _item.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 200,
                  width: double.infinity,
                  color: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: cs.onSurfaceVariant,
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _item.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(_item.description ?? 'No description'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderId == currentUserId();
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg.content),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
