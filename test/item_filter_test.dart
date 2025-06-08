import 'package:test/test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/utils/item_filter.dart';

void main() {
  final items = [
    Item(ownerId: '1', title: 'Wooden Chair', category: ItemCategory.furniture),
    Item(ownerId: '1', title: 'Dart Book', category: ItemCategory.books),
    Item(ownerId: '1', title: 'Laptop', category: ItemCategory.electronics),
    Item(ownerId: '1', title: 'Toaster', category: ItemCategory.appliances),
    Item(ownerId: '1', title: 'Jacket', category: ItemCategory.clothing),
  ];

  final cases = <({String description, String query, String category, List<String> expected})>[
    (
      description: 'search query filters items',
      query: 'book',
      category: 'All',
      expected: ['Dart Book'],
    ),
    (
      description: 'category filters items',
      query: '',
      category: 'Furniture',
      expected: ['Wooden Chair'],
    ),
    (
      description: 'combined search and category filters items',
      query: 'laptop',
      category: 'Electronics',
      expected: ['Laptop'],
    ),
    (
      description: 'appliances category works',
      query: '',
      category: 'Appliances',
      expected: ['Toaster'],
    ),
    (
      description: 'clothing category works',
      query: '',
      category: 'Clothing',
      expected: ['Jacket'],
    ),
  ];

  for (final c in cases) {
    test(c.description, () {
      final result = filterItems(items, c.query, c.category);
      expect(result.map((e) => e.title).toList(), c.expected);
    });
  }

  test('no match returns empty list', () {
    final result = filterItems(items, 'chair', 'Books');
    expect(result, isEmpty);
  });
}
