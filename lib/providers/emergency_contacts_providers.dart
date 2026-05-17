import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/emergency_contact_service.dart';

final emergencyContactServiceProvider =
    Provider<EmergencyContactService>((ref) => EmergencyContactService());

final emergencyContactsProvider = FutureProvider<List<EmergencyContact>>(
  (ref) async {
    final service = ref.watch(emergencyContactServiceProvider);
    return service.fetchContacts();
  },
  dependencies: [emergencyContactServiceProvider],
);
