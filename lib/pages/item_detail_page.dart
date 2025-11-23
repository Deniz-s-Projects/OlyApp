import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/item_service.dart';
import 'item_chat_page.dart';
import 'post_item_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;
  final ItemService? service;

  const ItemDetailPage({super.key, required this.item, this.service});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Item _item;
  late ItemService _service;
  final _ratingCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();
  final _noticeCtrl = TextEditingController();
  ItemNoticeSeverity _noticeSeverity = ItemNoticeSeverity.info;
  bool _savingNotice = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _service = widget.service ?? ItemService();
    _noticeCtrl.text = _item.notice?.text ?? '';
    _noticeSeverity = _item.notice?.severity ?? ItemNoticeSeverity.info;
  }

  @override
  void dispose() {
    _ratingCtrl.dispose();
    _reviewCtrl.dispose();
    _noticeCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestItem(BuildContext context) async {
    if (_item.id == null) return;
    final svc = _service;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await svc.requestItem(_item.id!);
      messenger.showSnackBar(const SnackBar(content: Text('Request sent!')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Color _noticeColor(ItemNoticeSeverity severity) {
    switch (severity) {
      case ItemNoticeSeverity.warning:
        return Colors.orange.shade100;
      case ItemNoticeSeverity.critical:
        return Colors.red.shade100;
      case ItemNoticeSeverity.info:
      default:
        return Colors.blue.shade100;
    }
  }

  Color _noticeTextColor(ItemNoticeSeverity severity, ColorScheme scheme) {
    switch (severity) {
      case ItemNoticeSeverity.warning:
        return Colors.orange.shade900;
      case ItemNoticeSeverity.critical:
        return Colors.red.shade900;
      case ItemNoticeSeverity.info:
      default:
        return scheme.primary;
    }
  }

  Future<void> _saveNotice() async {
    if (_item.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final text = _noticeCtrl.text.trim();
    if (text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Enter notice text or remove the notice.'),
        ),
      );
      return;
    }

    setState(() => _savingNotice = true);
    try {
      final updated = await _service.updateNotice(
        _item.id!,
        text: text,
        severity: _noticeSeverity,
      );
      if (!mounted) return;
      setState(() {
        _item = updated;
        _noticeSeverity = updated.notice?.severity ?? _noticeSeverity;
      });
      messenger.showSnackBar(const SnackBar(content: Text('Notice saved.')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save notice: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingNotice = false);
    }
  }

  Future<void> _clearNotice() async {
    if (_item.id == null) return;
    setState(() => _savingNotice = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await _service.clearNotice(_item.id!);
      if (!mounted) return;
      setState(() {
        _item = updated;
        _noticeCtrl.clear();
        _noticeSeverity = ItemNoticeSeverity.info;
      });
      messenger.showSnackBar(const SnackBar(content: Text('Notice removed.')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to remove notice: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingNotice = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    User? user;
    if (Hive.isBoxOpen('userBox')) {
      user = Hive.box<User>('userBox').get('currentUser');
    }
    final isOwner = user != null && user.id == _item.ownerId;
    final isAdmin = user?.isAdmin ?? false;
    final favBox = Hive.box('favoritesBox');
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.title),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 1,
        actions: [
          if (_item.id != null)
            ValueListenableBuilder(
              valueListenable: favBox.listenable(),
              builder: (context, Box box, _) {
                final ids =
                    (box.get('ids', defaultValue: const <int>[]) as List)
                        .cast<int>();
                final isFav = ids.contains(_item.id);
                return IconButton(
                  key: const Key('toggleFavoriteDetail'),
                  icon: Icon(isFav ? Icons.star : Icons.star_border),
                  onPressed: () {
                    final set = ids.toSet();
                    if (isFav) {
                      set.remove(_item.id);
                    } else {
                      set.add(_item.id as int);
                    }
                    box.put('ids', set.toList());
                  },
                );
              },
            ),
          if (isOwner) ...[
            IconButton(
              key: const Key('editItem'),
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PostItemPage(item: _item, service: _service),
                  ),
                );
              },
            ),
            IconButton(
              key: const Key('deleteItem'),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                if (_item.id == null) return;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Item'),
                    content: const Text(
                      'Are you sure you want to delete this item?',
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
                final svc = _service;
                await svc.deleteItem(_item.id!);
                if (context.mounted) Navigator.pop(context, true);
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Item Image
            _item.imageUrl != null
                ? Image.network(
                    _item.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Container(
                    height: 200,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price/Free Badge
                  Text(
                    _item.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_item.isFree)
                    Chip(
                      label: const Text('Free'),
                      backgroundColor: colorScheme.primary,
                      labelStyle: TextStyle(color: colorScheme.onPrimary),
                    )
                  else if (_item.price != null)
                    Text(
                      '\$${_item.price!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                  const SizedBox(height: 16),

                  if (_item.notice != null && _item.notice!.text.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _noticeColor(_item.notice!.severity),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _noticeTextColor(
                            _item.notice!.severity,
                            colorScheme,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notice (${_item.notice!.severity.name.toUpperCase()})',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: _noticeTextColor(
                                    _item.notice!.severity,
                                    colorScheme,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _item.notice!.text,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _noticeTextColor(
                                    _item.notice!.severity,
                                    colorScheme,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),

                  if (_item.notice != null && _item.notice!.text.isNotEmpty)
                    const SizedBox(height: 16),

                  // Description Section
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _item.description ?? 'No description provided.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  if (isAdmin) ...[
                    Text(
                      'Admin Notice',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noticeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Notice text',
                        hintText: 'Enter notice to show on this listing',
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ItemNoticeSeverity>(
                      value: _noticeSeverity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items: const [
                        DropdownMenuItem(
                          value: ItemNoticeSeverity.info,
                          child: Text('Info (blue)'),
                        ),
                        DropdownMenuItem(
                          value: ItemNoticeSeverity.warning,
                          child: Text('Warning (orange)'),
                        ),
                        DropdownMenuItem(
                          value: ItemNoticeSeverity.critical,
                          child: Text('Critical (red)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _noticeSeverity = val);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Save notice'),
                            onPressed: _savingNotice ? null : _saveNotice,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Remove notice'),
                            onPressed: _savingNotice ? null : _clearNotice,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Chat Owner'),
                          onPressed: () {
                            if (_item.id == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemChatPage(
                                  item: _item,
                                  service: _service,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Request'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                          onPressed: () {
                            _requestItem(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_item.completed && !isOwner) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ratingCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Rating (1-5)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                    ),
                    TextField(
                      controller: _reviewCtrl,
                      decoration: const InputDecoration(labelText: 'Review'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_item.id == null) return;
                        final rating = int.tryParse(_ratingCtrl.text) ?? 0;
                        await _service.submitRating(
                          _item.id!,
                          rating,
                          review: _reviewCtrl.text,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rating submitted')),
                          );
                        }
                      },
                      child: const Text('Submit Rating'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
