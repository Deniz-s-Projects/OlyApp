import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/item_detail_page.dart';
import 'package:oly_app/services/item_service.dart';

class FakeItemService extends ItemService {
  bool called = false;
  FakeItemService();
  @override
  Future<void> requestItem(int itemId) async {
    called = true;
  }
}

void main() {
  testWidgets('Request button triggers service and shows snackbar', (tester) async {
    final service = FakeItemService();
    final item = Item(id: 1, ownerId: 1, title: 'Chair');
    await tester.pumpWidget(MaterialApp(home: ItemDetailPage(item: item, service: service)));

    await tester.tap(find.text('Request'));
    await tester.pump();

    expect(service.called, isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
