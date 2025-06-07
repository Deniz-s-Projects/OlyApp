import '../models/models.dart';
import 'api_service.dart';

class ClubService extends ApiService {
  ClubService({super.client});

  Future<List<Club>> fetchClubs() async {
    return get('/clubs', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map((e) => Club.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<Club> createClub(Club club) async {
    return post('/clubs', club.toJson(), (json) {
      return Club.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<Club> joinClub(String clubId) async {
    return post('/clubs/$clubId/join', const {}, (json) {
      return Club.fromJson(json['data'] as Map<String, dynamic>);
    });
  }
}
