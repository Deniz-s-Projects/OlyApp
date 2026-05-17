import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/service_list_service.dart';

final serviceListServiceProvider =
    Provider<ServiceListService>((ref) => ServiceListService());

final serviceListingsProvider = FutureProvider<List<ServiceListing>>(
  (ref) async {
    final service = ref.watch(serviceListServiceProvider);
    return service.fetchListings();
  },
  dependencies: [serviceListServiceProvider],
);
