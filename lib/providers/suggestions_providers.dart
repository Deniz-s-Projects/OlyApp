import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/suggestion_service.dart';

final suggestionServiceProvider =
    Provider<SuggestionService>((ref) => SuggestionService());

final suggestionsProvider = FutureProvider<List<Suggestion>>(
  (ref) async {
    final service = ref.watch(suggestionServiceProvider);
    return service.fetchSuggestions();
  },
  dependencies: [suggestionServiceProvider],
);
