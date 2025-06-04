import '../models/models.dart';
import 'api_service.dart';

class MaintenanceService extends ApiService {
  MaintenanceService({super.client});

  Future<List<MaintenanceRequest>> fetchRequests() async {
    return get('/maintenance', (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => MaintenanceRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<MaintenanceRequest> createRequest(MaintenanceRequest request) async {
    return post('/maintenance', request.toJson(), (json) {
      return MaintenanceRequest.fromJson(json as Map<String, dynamic>);
    });
  }
}
