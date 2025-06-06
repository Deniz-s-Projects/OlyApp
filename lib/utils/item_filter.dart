import '../models/models.dart';

String itemCategory(Item item) {
  switch (item.category) {
    case ItemCategory.furniture:
      return 'Furniture';
    case ItemCategory.books:
      return 'Books';
    case ItemCategory.electronics:
      return 'Electronics';
    case ItemCategory.appliances:
      return 'Appliances';
    case ItemCategory.clothing:
      return 'Clothing';
    default:
      return 'Other';
  }
}

List<Item> filterItems(List<Item> items, String query, String selectedCategory) {
  final lower = query.toLowerCase();
  return items.where((item) {
    final matchesSearch = item.title.toLowerCase().contains(lower);
    final matchesCat = selectedCategory == 'All' ||
        itemCategory(item) == selectedCategory;
    return matchesSearch && matchesCat;
  }).toList();
}
