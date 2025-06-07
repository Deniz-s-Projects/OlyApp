import '../models/models.dart';
import 'api_service.dart';

class PollService extends ApiService {
  PollService({super.client});

  Future<List<Poll>> fetchPolls() async {
    return get('/polls', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map((e) => Poll.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<Poll> createPoll(Poll poll) async {
    return post('/polls', poll.toJson(), (json) {
      return Poll.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<void> vote(String pollId, int option) async {
    await post('/polls/$pollId/vote', {'option': option}, (_) => null);
  }

  Future<void> deletePoll(String id) async {
    await delete('/polls/$id', (_) => null);
  }
}
