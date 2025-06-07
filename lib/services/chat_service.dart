import '../models/models.dart';
import 'api_service.dart';

class ChatService extends ApiService {
  ChatService({super.client});

  Future<ChatChannel> createChannel(String name, {List<String> participants = const []}) async {
    return post('/channels', {
      'name': name,
      'participants': participants,
    }, (json) {
      return ChatChannel.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<ChatChannel> addParticipant(String channelId, String userId) async {
    return post('/channels/$channelId/participants', {'userId': userId}, (json) {
      return ChatChannel.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<ChatChannel> removeParticipant(String channelId, String userId) async {
    return delete('/channels/$channelId/participants/$userId', (json) {
      return ChatChannel.fromJson(json['data'] as Map<String, dynamic>);
    });
  }

  Future<List<Message>> fetchMessages(String channelId) async {
    return get('/channels/$channelId/messages', (json) {
      final list = json['data'] as List<dynamic>;
      return list.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<Message> sendMessage(String channelId, String content) async {
    return post('/channels/$channelId/messages', {
      'content': content,
    }, (json) {
      return Message.fromJson(json['data'] as Map<String, dynamic>);
    });
  }
}
