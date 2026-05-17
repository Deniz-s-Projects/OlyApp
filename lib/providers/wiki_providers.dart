import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/wiki_service.dart';

final wikiServiceProvider = Provider<WikiService>((ref) => WikiService());

final wikiArticlesProvider = FutureProvider<List<WikiArticle>>(
  (ref) async {
    final service = ref.watch(wikiServiceProvider);
    return service.fetchArticles();
  },
  dependencies: [wikiServiceProvider],
);
