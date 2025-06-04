import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/utils/item_filter.dart';

void main() {
  final items = [
    Item(ownerId: 1, title: 'Wooden Chair', category: ItemCategory.furniture),
    Item(ownerId: 1, title: 'Dart Book', category: ItemCategory.books),
    Item(ownerId: 1, title: 'Laptop', category: ItemCategory.electronics),
  ];

  test('search query filters items', () {
    final result = filterItems(items, 'book', 'All');
    expect(result.map((e) => e.title).toList(), ['Dart Book']);
  });

  test('category filters items', () {
    final result = filterItems(items, '', 'Furniture');
    expect(result.map((e) => e.title).toList(), ['Wooden Chair']);
  });

  test('combined search and category filters items', () {
    final result = filterItems(items, 'laptop', 'Electronics');
    expect(result.map((e) => e.title).toList(), ['Laptop']);
  });

  test('no match returns empty list', () {
    final result = filterItems(items, 'chair', 'Books');
    expect(result, isEmpty);
  });
}
