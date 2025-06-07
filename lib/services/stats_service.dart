import 'api_service.dart';

class StatsService extends ApiService {
  StatsService({super.client});

  Future<Map<String, dynamic>> fetchStats() async {
    return get('/stats', (json) {
      final map = Map<String, dynamic>.from(json['data'] as Map);
      return map;
    });
  }

  Future<Map<String, List<int>>> fetchMonthlyStats() async {
    return get('/stats/monthly', (json) {
      final map = Map<String, dynamic>.from(json['data'] as Map);
      return map.map((k, v) => MapEntry(k, List<int>.from(v as List)));
    });
  }
}
