import '../models/models.dart';
import 'api_service.dart';

class ItemService extends ApiService {
  ItemService({super.client});

  Future<List<Item>> fetchItems() async {
    return get('/items', (json) {
      final list = json as List<dynamic>;
      return list.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<Item> createItem(Item item) async {
    return post('/items', item.toJson(),
        (json) => Item.fromJson(json as Map<String, dynamic>));
  }
}
