import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/item_providers.dart';
import '../services/item_service.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';
import 'post_item_page.dart';

class ItemExchangePage extends StatelessWidget {
  /// Optional service override. Mainly used by widget tests; production
  /// callers rely on the top-level [ProviderScope] in main.dart.
  final ItemService? service;

  const ItemExchangePage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _ItemExchangeBody();
    }
    return ProviderScope(
      overrides: [itemServiceProvider.overrideWithValue(service!)],
      child: const _ItemExchangeBody(),
    );
  }
}

class _ItemExchangeBody extends ConsumerStatefulWidget {
  const _ItemExchangeBody();

  @override
  ConsumerState<_ItemExchangeBody> createState() => _ItemExchangeBodyState();
}

class _ItemExchangeBodyState extends ConsumerState<_ItemExchangeBody> {
  final _searchCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();

  static const _categories = [
    'All',
    'Furniture',
    'Books',
    'Electronics',
    'Appliances',
    'Clothing',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final filters = ref.watch(itemFiltersProvider);
    final filteredItems = ref.watch(filteredItemsProvider);
    final favorites = ref.watch(favoritesProvider);
    final filtersNotifier = ref.read(itemFiltersProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field with refresh
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search items…',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: filtersNotifier.setSearch,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(itemsProvider),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final selected = cat == filters.selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => filtersNotifier.setCategory(cat),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Favorites'),
                selected: filters.onlyFavorites,
                onSelected: filtersNotifier.setOnlyFavorites,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceCtrl,
                    decoration: const InputDecoration(labelText: 'Min Price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (val) =>
                        filtersNotifier.setMinPrice(double.tryParse(val)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxPriceCtrl,
                    decoration: const InputDecoration(labelText: 'Max Price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (val) =>
                        filtersNotifier.setMaxPrice(double.tryParse(val)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            DropdownButton<String>(
              key: const ValueKey('sortDropdown'),
              value: filters.sortOrder,
              isExpanded: true,
              onChanged: (val) {
                if (val == null) return;
                filtersNotifier.setSortOrder(val);
              },
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
                DropdownMenuItem(
                  value: 'priceAsc',
                  child: Text('Price: Low to High'),
                ),
                DropdownMenuItem(
                  value: 'priceDesc',
                  child: Text('Price: High to Low'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Grid of items
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(itemsProvider),
                child: itemsAsync.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredItems.isEmpty
                        ? const Center(child: Text('No items found.'))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: filteredItems.length,
                            itemBuilder: (ctx, idx) {
                              final item = filteredItems[idx];
                              final isFav =
                                  item.id != null && favorites.contains(item.id);
                              return Stack(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ItemDetailPage(item: item),
                                        ),
                                      );
                                    },
                                    child: ItemCard(
                                      title: item.title,
                                      averageRating: item.ratings.isNotEmpty
                                          ? item.averageRating
                                          : null,
                                    ),
                                  ),
                                  if (item.id != null)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        key: Key('toggleFavorite_${item.id}'),
                                        icon: Icon(
                                          isFav
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () => ref
                                            .read(favoritesProvider.notifier)
                                            .toggle(item.id as int),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),

      // FAB to post a new listing. PostItemPage invalidates itemsProvider
      // itself on success, so we don't need a return-value side-effect here.
      floatingActionButton: FloatingActionButton(
        heroTag: 'exchangeFab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostItemPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
