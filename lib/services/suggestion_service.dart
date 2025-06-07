import '../models/models.dart';
import 'api_service.dart';

class SuggestionService extends ApiService {
  SuggestionService({super.client});

  Future<Suggestion> createSuggestion(Suggestion suggestion) async {
    return post(
      '/suggestions',
      suggestion.toJson(),
      (json) => Suggestion.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<List<Suggestion>> fetchSuggestions() async {
    return get('/suggestions', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Suggestion> updateSuggestion(Suggestion suggestion) async {
    if (suggestion.id == null) throw ArgumentError('id required');
    return put(
      '/suggestions/${suggestion.id}',
      suggestion.toJson(),
      (json) => Suggestion.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteSuggestion(String id) async {
    await delete('/suggestions/$id', (_) => null);
  }
}
