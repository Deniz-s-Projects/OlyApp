import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/item_exchange_page.dart';
import 'package:oly_app/pages/item_detail_page.dart';
import 'package:oly_app/services/item_service.dart';
import 'package:oly_app/widgets/item_card.dart';

class FakeItemService extends ItemService {
  final List<Item> items;
  FakeItemService(this.items);
  @override
  Future<List<Item>> fetchItems() async => items;
}

void main() {
  testWidgets('Search text or category filters items', (tester) async {
    final service = FakeItemService([
      Item(ownerId: 1, title: 'Dart Book', category: ItemCategory.books),
      Item(ownerId: 1, title: 'Laptop', category: ItemCategory.electronics),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: ItemExchangePage(service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dart Book'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'laptop');
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Dart Book'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();

    expect(find.text('Dart Book'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
  });

  testWidgets('Tapping item opens detail page', (tester) async {
    final item = Item(
      ownerId: 1,
      title: 'Chair',
      category: ItemCategory.furniture,
    );
    final service = FakeItemService([item]);

    await tester.pumpWidget(
      MaterialApp(home: ItemExchangePage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ItemCard, 'Chair'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemDetailPage), findsOneWidget);
  });
}
