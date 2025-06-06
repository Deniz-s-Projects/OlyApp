import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/item_detail_page.dart';
import 'package:oly_app/pages/item_chat_page.dart';
import 'package:oly_app/services/item_service.dart';
import 'dart:io';
import 'package:hive/hive.dart';

class FakeItemService extends ItemService {
  FakeItemService();
  @override
  Future<List<Message>> fetchMessages(int itemId) async => [];
  @override
  Future<Message> sendMessage(Message message) async => message;
}

void main() {
  late Directory dir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    await Hive.openBox('favoritesBox');
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('Chat Owner opens ItemChatPage', (tester) async {
    final item = Item(id: 1, ownerId: '1', title: 'Chair');
    await tester.pumpWidget(
      MaterialApp(home: ItemDetailPage(item: item, service: FakeItemService())),
    );

    await tester.tap(find.text('Chat Owner'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemChatPage), findsOneWidget);
  });
}
