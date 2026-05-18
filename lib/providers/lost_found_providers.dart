import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/lost_found_service.dart';

final lostFoundServiceProvider =
    Provider<LostFoundService>((ref) => LostFoundService());

class LostFoundFilters {
  final String search;
  // 'all', 'lost', 'found'
  final String type;
  // 'all', 'true', 'false'
  final String resolved;

  const LostFoundFilters({
    this.search = '',
    this.type = 'all',
    this.resolved = 'all',
  });

  LostFoundFilters copyWith({String? search, String? type, String? resolved}) {
    return LostFoundFilters(
      search: search ?? this.search,
      type: type ?? this.type,
      resolved: resolved ?? this.resolved,
    );
  }
}

class LostFoundFiltersNotifier extends Notifier<LostFoundFilters> {
  @override
  LostFoundFilters build() => const LostFoundFilters();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setType(String value) => state = state.copyWith(type: value);
  void setResolved(String value) => state = state.copyWith(resolved: value);
}

final lostFoundFiltersProvider =
    NotifierProvider<LostFoundFiltersNotifier, LostFoundFilters>(
        LostFoundFiltersNotifier.new);

final lostFoundItemsProvider = FutureProvider<List<LostItem>>(
  (ref) async {
    ref.keepAlive();
    final filters = ref.watch(lostFoundFiltersProvider);
    final service = ref.watch(lostFoundServiceProvider);
    return service.fetchItems(
      search: filters.search,
      type: filters.type == 'all' ? null : filters.type,
      resolved: filters.resolved == 'all' ? null : filters.resolved == 'true',
    );
  },
  dependencies: [lostFoundServiceProvider, lostFoundFiltersProvider],
);
