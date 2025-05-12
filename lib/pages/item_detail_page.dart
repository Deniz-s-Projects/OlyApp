import 'package:flutter/material.dart';

class ItemDetailPage extends StatelessWidget {
  final String itemTitle;
  final String? itemImageUrl;
  final String? itemDescription;
  final double? itemPrice;
  final bool isFree;

  const ItemDetailPage({
    super.key,
    required this.itemTitle,
    this.itemImageUrl,
    this.itemDescription,
    this.itemPrice,
    this.isFree = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(itemTitle),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Item Image
            itemImageUrl != null
                ? Image.network(
              itemImageUrl!,
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
                    itemTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  if (isFree)
                    Chip(
                      label: const Text('Free'),
                      backgroundColor: colorScheme.primary,
                      labelStyle: TextStyle(color: colorScheme.onPrimary),
                    )
                  else if (itemPrice != null)
                    Text(
                      '\$${itemPrice!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                  const SizedBox(height: 16),

                  // Description Section
                  Text(
                    'Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: colorScheme.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itemDescription ?? 'No description provided.',
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
                            // TODO: navigate to chat screen
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
                            // TODO: send request action
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
