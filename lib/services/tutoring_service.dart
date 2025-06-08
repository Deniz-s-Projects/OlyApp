import '../models/models.dart';
import 'api_service.dart';

class TutoringService extends ApiService {
  TutoringService({super.client});

  Future<List<TutoringPost>> fetchPosts() async {
    return get('/tutoring', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => TutoringPost.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<TutoringPost> createPost(TutoringPost data) async {
    return post('/tutoring', data.toJson(), (json) {
      return TutoringPost.fromJson(json['data'] as Map<String, dynamic>);
    });
  }
}
