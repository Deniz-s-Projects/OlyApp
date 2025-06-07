import 'api_service.dart';

class StatsService extends ApiService {
  StatsService({super.client});

  Future<Map<String, dynamic>> fetchStats() async {
    return get('/stats', (json) {
      final map = Map<String, dynamic>.from(json['data'] as Map);
      return map;
    });
  }
}
