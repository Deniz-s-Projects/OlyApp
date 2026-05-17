import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';
import '../services/item_service.dart';
import '../utils/item_filter.dart';

/// Single source of truth for the [ItemService] instance.
/// Overridden in tests via [ProviderScope.overrides].
final itemServiceProvider = Provider<ItemService>((ref) => ItemService());

/// Loads the catalogue of items. Refresh by invalidating the provider
/// (e.g. `ref.invalidate(itemsProvider)`).
///
/// `dependencies: [itemServiceProvider]` is required because some callers
/// (e.g. `ItemExchangePage(service: …)`) override `itemServiceProvider` in
/// a nested `ProviderScope`. Without declaring the dependency Riverpod
/// would re-use the outer scope's instance and ignore the override.
final itemsProvider = FutureProvider<List<Item>>(
  (ref) async {
    final service = ref.watch(itemServiceProvider);
    return service.fetchItems();
  },
  dependencies: [itemServiceProvider],
);

/// Filter and sort settings for the item exchange page.
class ItemFilters {
  final String search;
  final String selectedCategory;
  final double? minPrice;
  final double? maxPrice;
  final bool onlyFavorites;
  final String sortOrder;

  const ItemFilters({
    this.search = '',
    this.selectedCategory = 'All',
    this.minPrice,
    this.maxPrice,
    this.onlyFavorites = false,
    this.sortOrder = 'newest',
  });

  ItemFilters copyWith({
    String? search,
    String? selectedCategory,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    bool? onlyFavorites,
    String? sortOrder,
  }) {
    return ItemFilters(
      search: search ?? this.search,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      minPrice: identical(minPrice, _sentinel) ? this.minPrice : minPrice as double?,
      maxPrice: identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as double?,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  static const _sentinel = Object();
}

class ItemFiltersNotifier extends Notifier<ItemFilters> {
  @override
  ItemFilters build() => const ItemFilters();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setCategory(String value) => state = state.copyWith(selectedCategory: value);
  void setMinPrice(double? value) => state = state.copyWith(minPrice: value);
  void setMaxPrice(double? value) => state = state.copyWith(maxPrice: value);
  void setOnlyFavorites(bool value) => state = state.copyWith(onlyFavorites: value);
  void setSortOrder(String value) => state = state.copyWith(sortOrder: value);
}

final itemFiltersProvider =
    NotifierProvider<ItemFiltersNotifier, ItemFilters>(ItemFiltersNotifier.new);

/// Favorites are persisted in the Hive `favoritesBox`. The notifier mirrors
/// the box so widgets re-render on toggle without re-reading Hive directly.
class FavoritesNotifier extends Notifier<Set<int>> {
  static const _boxName = 'favoritesBox';
  static const _key = 'ids';

  @override
  Set<int> build() {
    if (!Hive.isBoxOpen(_boxName)) return <int>{};
    final box = Hive.box(_boxName);
    return (box.get(_key, defaultValue: const <int>[]) as List).cast<int>().toSet();
  }

  void toggle(int id) {
    final next = state.toSet();
    if (!next.add(id)) next.remove(id);
    state = next;
    if (Hive.isBoxOpen(_boxName)) {
      Hive.box(_boxName).put(_key, next.toList());
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<int>>(FavoritesNotifier.new);

/// The item list after the user's current filters, favorites, and sort.
///
/// Inherits the scoping of [itemsProvider] so that nested
/// `itemServiceProvider` overrides flow through correctly.
final filteredItemsProvider = Provider<List<Item>>(
  (ref) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final filters = ref.watch(itemFiltersProvider);
    final favorites = ref.watch(favoritesProvider);

    var results =
        filterItems(items, filters.search, filters.selectedCategory);
    if (filters.minPrice != null) {
      results = results
          .where((item) => (item.price ?? 0) >= filters.minPrice!)
          .toList();
    }
    if (filters.maxPrice != null) {
      results = results
          .where((item) => (item.price ?? 0) <= filters.maxPrice!)
          .toList();
    }
    if (filters.onlyFavorites) {
      results = results
          .where((item) => item.id != null && favorites.contains(item.id))
          .toList();
    }
    switch (filters.sortOrder) {
      case 'priceAsc':
        results.sort((a, b) =>
            (a.price ?? double.infinity).compareTo(b.price ?? double.infinity));
        break;
      case 'priceDesc':
        results.sort((a, b) =>
            (b.price ?? -double.infinity)
                .compareTo(a.price ?? -double.infinity));
        break;
      default:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return results;
  },
  dependencies: [itemsProvider],
);
