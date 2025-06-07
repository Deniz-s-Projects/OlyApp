import '../models/models.dart';
import 'api_service.dart';

class WikiService extends ApiService {
  WikiService({super.client});

  Future<List<WikiArticle>> fetchArticles() async {
    return get('/wiki', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => WikiArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<WikiArticle> fetchArticle(int id) async {
    return get('/wiki/$id', (json) {
      return WikiArticle.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<WikiArticle> addArticle(WikiArticle article) async {
    return post(
      '/wiki',
      article.toJson(),
      (json) => WikiArticle.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<WikiArticle> updateArticle(WikiArticle article) async {
    if (article.id == null) throw ArgumentError('id required');
    return put(
      '/wiki/${article.id}',
      article.toJson(),
      (json) => WikiArticle.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteArticle(int id) async {
    await delete('/wiki/$id', (_) => null);
  }
}
