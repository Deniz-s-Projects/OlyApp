import 'package:flutter/material.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';
import 'post_item_page.dart';
import '../models/models.dart';
import '../services/item_service.dart';
import '../utils/item_filter.dart';

class ItemExchangePage extends StatefulWidget {
  final ItemService? service;
  const ItemExchangePage({super.key, this.service});

  @override
  State<ItemExchangePage> createState() => _ItemExchangePageState();
}

class _ItemExchangePageState extends State<ItemExchangePage> {
  late final ItemService _service;
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final _categories = ['All', 'Furniture', 'Books', 'Electronics'];

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];

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
  }

  void _filter() {
    final query = _searchCtrl.text;
    setState(() {
      _filteredItems = filterItems(_allItems, query, _selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field
            TextField(
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
              onChanged: (_) => _filter(),
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
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(item: item),
                        ),
                      );
                    },
                    child: ItemCard(title: item.title),
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
