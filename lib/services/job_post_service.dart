import '../models/models.dart';
import 'api_service.dart';

class JobPostService extends ApiService {
  JobPostService({super.client});

  Future<List<JobPost>> fetchPosts() async {
    return get('/job_posts', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => JobPost.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<JobPost> createPost(JobPost job) async {
    return post(
      '/job_posts',
      job.toJson(),
      (json) => JobPost.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<JobPost> updatePost(JobPost job) async {
    if (job.id == null) throw ArgumentError('id required');
    return put(
      '/job_posts/${job.id}',
      job.toJson(),
      (json) => JobPost.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deletePost(String id) async {
    await delete('/job_posts/$id', (_) => null);
  }
}
