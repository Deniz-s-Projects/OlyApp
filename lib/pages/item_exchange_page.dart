import 'package:flutter/material.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';

class ItemExchangePage extends StatefulWidget {
  const ItemExchangePage({super.key});

  @override
  State<ItemExchangePage> createState() => _ItemExchangePageState();
}

class _ItemExchangePageState extends State<ItemExchangePage> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final _categories = ['All', 'Furniture', 'Books', 'Electronics'];

  // TODO: hook up to your real data source
  List<String> _allItems = ['Table', 'Textbook', 'Lamp', 'Chair', 'Laptop'];
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_allItems);
  }

  void _filter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesSearch = item.toLowerCase().contains(query);
        final matchesCat = _selectedCategory == 'All'
            || (itemCategory(item) == _selectedCategory);
        return matchesSearch && matchesCat;
      }).toList();
    });
  }

  String itemCategory(String item) {
    // Replace with your real logic
    if (item == 'Table' || item == 'Chair') return 'Furniture';
    if (item == 'Textbook') return 'Books';
    if (item == 'Laptop') return 'Electronics';
    return 'All';
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
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
                  final title = _filteredItems[idx];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(itemTitle: title),
                        ),
                      );
                    },
                    child: ItemCard(title: title),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB to post a new listing
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to PostItemPage()
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
