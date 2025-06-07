import '../models/models.dart';
import 'api_service.dart';

class ServiceListService extends ApiService {
  ServiceListService({super.client});

  Future<List<ServiceListing>> fetchListings() async {
    return get('/services', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => ServiceListing.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<ServiceListing> addListing(ServiceListing listing) async {
    return post(
      '/services',
      listing.toJson(),
      (json) => ServiceListing.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<ServiceListing> updateListing(ServiceListing listing) async {
    if (listing.id == null) throw ArgumentError('id required');
    return put(
      '/services/${listing.id}',
      listing.toJson(),
      (json) => ServiceListing.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<void> deleteListing(int id) async {
    await delete('/services/$id', (_) => null);
  }

  Future<void> submitRating(int listingId, int rating, {String? review}) async {
    await post('/services/$listingId/ratings',
        {'rating': rating, 'review': review}, (_) => null);
  }

  Future<List<ServiceRating>> fetchRatings(int listingId) async {
    return get('/services/$listingId/ratings', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => ServiceRating.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
