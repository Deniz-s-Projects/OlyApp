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

  Future<List<Message>> fetchMessages(int requestId) async {
    return get('/maintenance/$requestId/messages', (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Message> sendMessage(Message message) async {
    return post('/maintenance/${message.requestId}/messages', message.toJson(),
        (json) => Message.fromJson(json as Map<String, dynamic>));
  }

  Future<MaintenanceRequest> updateStatus(int id, String status) async {
    return post('/maintenance/$id', {'status': status},
        (json) => MaintenanceRequest.fromJson(json as Map<String, dynamic>));
  }
}
