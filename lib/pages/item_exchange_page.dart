import 'package:flutter/material.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';
import 'post_item_page.dart';
import '../models/models.dart';
import '../services/item_service.dart';
import '../utils/item_filter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ItemExchangePage extends StatefulWidget {
  final ItemService? service;
  const ItemExchangePage({super.key, this.service});

  @override
  State<ItemExchangePage> createState() => _ItemExchangePageState();
}

class _ItemExchangePageState extends State<ItemExchangePage> {
  late final ItemService _service;
  final _searchCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  String _selectedCategory = 'All';
  bool _onlyFavorites = false;

  final _categories = [
    'All',
    'Furniture',
    'Books',
    'Electronics',
    'Appliances',
    'Clothing'
  ];

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];

  Set<int> _favoriteIds() {
    final box = Hive.box('favoritesBox');
    return (box.get('ids', defaultValue: const <int>[]) as List)
        .cast<int>()
        .toSet();
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ItemService();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _service.fetchItems();
    setState(() {
      _allItems = items;
      _filteredItems = List.from(_allItems);
    });
    _filter();
  }

  void _filter() {
    final query = _searchCtrl.text;
    final minPrice = double.tryParse(_minPriceCtrl.text);
    final maxPrice = double.tryParse(_maxPriceCtrl.text);
    setState(() {
      var results = filterItems(_allItems, query, _selectedCategory);
      if (minPrice != null) {
        results = results
            .where((item) => (item.price ?? 0) >= minPrice)
            .toList();
      }
      if (maxPrice != null) {
        results = results
            .where((item) => (item.price ?? 0) <= maxPrice)
            .toList();
      }
      if (_onlyFavorites) {
        final favs = _favoriteIds();
        results =
            results
                .where((item) => item.id != null && favs.contains(item.id))
                .toList();
      }
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => _filter(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadItems,
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
                  final selected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                        _filter();
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Favorites'),
                selected: _onlyFavorites,
                onSelected: (val) {
                  setState(() {
                    _onlyFavorites = val;
                    _filter();
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Min Price'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _filter(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxPriceCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Max Price'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _filter(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Grid of items
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _filteredItems.length,
                itemBuilder: (ctx, idx) {
                  final item = _filteredItems[idx];
                  final favs = _favoriteIds();
                  final isFav = item.id != null && favs.contains(item.id);
                  return Stack(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailPage(item: item),
                            ),
                          );
                        },
                        child: ItemCard(
                          title: item.title,
                          averageRating:
                              item.ratings.isNotEmpty ? item.averageRating : null,
                        ),
                      ),
                      if (item.id != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            key: Key('toggleFavorite_${item.id}'),
                            icon: Icon(
                              isFav ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              final box = Hive.box('favoritesBox');
                              final set = favs.toSet();
                              if (isFav) {
                                set.remove(item.id);
                              } else {
                                set.add(item.id as int);
                              }
                              box.put('ids', set.toList());
                              _filter();
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB to post a new listing
      floatingActionButton: FloatingActionButton(
        heroTag: 'exchangeFab',
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PostItemPage()),
          );
          if (created == true) {
            _loadItems();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
