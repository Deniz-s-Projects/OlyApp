import '../models/models.dart';
import 'api_service.dart';

/// Service for item-related API calls.
class ItemService extends ApiService {
  ItemService({super.client});

  /// Fetches all marketplace items.
  Future<List<Item>> fetchItems() async {
    return get('/items', (json) {
      final list = json['data'] as List<dynamic>;
      return list
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Creates a new item listing.
  Future<Item> createItem(Item item) async {
    return post(
      '/items',
      item.toJson(),
      (json) => Item.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Retrieves messages for the item with [itemId].
  Future<List<Message>> fetchMessages(int itemId) async {
    return get('/items/$itemId/messages', (json) {
      final list = json as List<dynamic>;
      return list
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// Sends a chat [message] for its associated item.
  Future<Message> sendMessage(Message message) async {
    return post(
      '/items/${message.requestId}/messages',
      message.toJson(),
      (json) => Message.fromJson(json as Map<String, dynamic>),
    );
  }
}
