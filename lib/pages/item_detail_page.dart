import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/item_service.dart';
import 'item_chat_page.dart';
import 'post_item_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  final ItemService? service;

  const ItemDetailPage({super.key, required this.item, this.service});

  Future<void> _requestItem(BuildContext context) async {
    if (item.id == null) return;
    final svc = service ?? ItemService();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await svc.requestItem(item.id!);
      messenger.showSnackBar(
          const SnackBar(content: Text('Request sent!')));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    User? user;
    if (Hive.isBoxOpen('userBox')) {
      user = Hive.box<User>('userBox').get('currentUser');
    }
    final isOwner = user != null && user.id == item.ownerId;
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 1,
        actions: isOwner
            ? [
                IconButton(
                  key: const Key('editItem'),
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostItemPage(
                          item: item,
                          service: service,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  key: const Key('deleteItem'),
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    if (item.id == null) return;
                    final svc = service ?? ItemService();
                    await svc.deleteItem(item.id!);
                    if (context.mounted) Navigator.pop(context, true);
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Item Image
            item.imageUrl != null
                ? Image.network(
                  item.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                    item.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (item.isFree)
                    Chip(
                      label: const Text('Free'),
                      backgroundColor: colorScheme.primary,
                      labelStyle: TextStyle(color: colorScheme.onPrimary),
                    )
                  else if (item.price != null)
                    Text(
                      '\$${item.price!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

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
                    item.description ?? 'No description provided.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Chat Owner'),
                          onPressed: () {
                            if (item.id == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ItemChatPage(
                                      item: item,
                                      service: service,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
