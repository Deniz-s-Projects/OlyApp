import '../models/models.dart';
import 'api_service.dart';

class EmergencyContactService extends ApiService {
  EmergencyContactService({super.client});

  Future<List<EmergencyContact>> fetchContacts() async {
    return get('/emergency_contacts', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<EmergencyContact> createContact(EmergencyContact contact) async {
    return post(
      '/emergency_contacts',
      contact.toJson(),
      (json) => EmergencyContact.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<EmergencyContact> updateContact(EmergencyContact contact) async {
    if (contact.id == null) throw ArgumentError('id required');
    return put(
      '/emergency_contacts/${contact.id}',
      contact.toJson(),
      (json) => EmergencyContact.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteContact(String id) async {
    await delete('/emergency_contacts/$id', (_) => null);
  }
}
