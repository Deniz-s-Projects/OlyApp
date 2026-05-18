import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/event_service.dart';

final eventServiceProvider =
    Provider<EventService>((ref) => EventService());

/// All events known to the server. Refresh by invalidating the provider.
///
/// `dependencies: [eventServiceProvider]` lets nested `ProviderScope`
/// overrides of [eventServiceProvider] flow through correctly.
final eventsProvider = FutureProvider<List<CalendarEvent>>(
  (ref) async {
    // Cache survives back-navigation so returning to Calendar is instant
    // instead of triggering a refetch. Pull-to-refresh and `ref.invalidate`
    // (used after writes) still bust the cache when needed.
    ref.keepAlive();
    final service = ref.watch(eventServiceProvider);
    return service.fetchEvents();
  },
  dependencies: [eventServiceProvider],
);

/// Currently-selected category filter on the calendar page. 'All' shows
/// every event.
class CalendarCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  void set(String value) => state = value;
}

final calendarCategoryProvider =
    NotifierProvider<CalendarCategoryNotifier, String>(
        CalendarCategoryNotifier.new);

/// Distinct event categories present in the loaded events, with 'All'
/// always in front. Recomputes whenever the events change.
final calendarCategoriesProvider = Provider<List<String>>(
  (ref) {
    final events = ref.watch(eventsProvider).valueOrNull ??
        const <CalendarEvent>[];
    final result = <String>['All'];
    for (final e in events) {
      final cat = e.category;
      if (cat != null && cat.isNotEmpty && !result.contains(cat)) {
        result.add(cat);
      }
    }
    return result;
  },
  dependencies: [eventsProvider],
);

/// Events grouped by day for [TableCalendar.eventLoader]. Filtered to the
/// currently-selected category.
final eventsByDayProvider = Provider<Map<DateTime, List<CalendarEvent>>>(
  (ref) {
    final events = ref.watch(eventsProvider).valueOrNull ??
        const <CalendarEvent>[];
    final category = ref.watch(calendarCategoryProvider);
    final map = <DateTime, List<CalendarEvent>>{};
    for (final e in events) {
      if (category != 'All' && e.category != category) continue;
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  },
  dependencies: [eventsProvider, calendarCategoryProvider],
);
