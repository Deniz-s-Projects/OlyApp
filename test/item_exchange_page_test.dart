import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/item_exchange_page.dart';
import 'package:oly_app/pages/item_detail_page.dart';
import 'package:oly_app/services/item_service.dart';
import 'package:oly_app/widgets/item_card.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class FakeItemService extends ItemService {
  final List<Item> items;
  Item? updated;
  int? deletedId;
  FakeItemService(this.items);
  @override
  Future<List<Item>> fetchItems() async => items;

  @override
  Future<Item> updateItem(Item item) async {
    updated = item;
    return item;
  }

  @override
  Future<void> deleteItem(int id) async {
    deletedId = id;
  }
}

class DelayedItemService extends FakeItemService {
  DelayedItemService(super.items);
  @override
  Future<List<Item>> fetchItems() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return super.fetchItems();
  }
}

void main() {
  late Directory dir;

  setUpAll(() {
    Hive.registerAdapter(UserAdapter());
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    await Hive.openBox<User>('userBox');
    await Hive.openBox('favoritesBox');
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('Shows progress indicator while loading', (tester) async {
    final service = DelayedItemService([]);
    await tester.pumpWidget(
      MaterialApp(home: ItemExchangePage(service: service)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Favorites filter shows only bookmarked items', (tester) async {
    await tester.runAsync(() async {
      final service = FakeItemService([
        Item(id: 1, ownerId: '1', title: 'Fav', category: ItemCategory.books),
        Item(id: 2, ownerId: '1', title: 'Other', category: ItemCategory.books),
      ]);

      await tester.pumpWidget(
        MaterialApp(home: ItemExchangePage(service: service)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('toggleFavorite_1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('Fav'), findsOneWidget);
      expect(find.text('Other'), findsNothing);
    });
  });

  testWidgets('Detail page toggles favorite', (tester) async {
    await tester.runAsync(() async {
      final item = Item(id: 5, ownerId: '2', title: 'Chair');

      await tester.pumpWidget(MaterialApp(home: ItemDetailPage(item: item)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('toggleFavoriteDetail')));
      await tester.pumpAndSettle();

      final favs = (Hive.box('favoritesBox').get('ids') as List?)?.cast<int>();
      expect(favs, contains(5));
    });
  });
  testWidgets('Search text or category filters items', (tester) async {
    final service = FakeItemService([
      Item(ownerId: '1', title: 'Dart Book', category: ItemCategory.books),
      Item(ownerId: '1', title: 'Laptop', category: ItemCategory.electronics),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: ItemExchangePage(service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dart Book'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'laptop');
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Dart Book'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();

    expect(find.text('Dart Book'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
  });

  testWidgets('Tapping item opens detail page', (tester) async {
    final item = Item(
      ownerId: '1',
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

  testWidgets('Owner can edit an item', (tester) async {
    await tester.runAsync(() async {
      await Hive.box<User>('userBox').put(
        'currentUser',
        User(id: '1', name: 'Owner', email: 'o@test.com', isListed: false),
      );

      final item = Item(
        id: 1,
        ownerId: '1',
        title: 'Old',
        category: ItemCategory.books,
      );
      final service = FakeItemService([item]);

      await tester.pumpWidget(
        MaterialApp(home: ItemDetailPage(item: item, service: service)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('editItem')), findsOneWidget);
      await tester.tap(find.byKey(const Key('editItem')));
      await tester.pumpAndSettle();

      // title field prefilled
      final titleEditable = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).first,
          matching: find.byType(EditableText),
        ),
      );
      expect(titleEditable.controller.text, 'Old');

      await tester.enterText(find.byType(TextFormField).first, 'New');
      await tester.tap(find.text('Update Item'));
      await tester.pump();

      expect(service.updated?.title, 'New');
    });
  });

  testWidgets('Owner can delete an item', (tester) async {
    await tester.runAsync(() async {
      await Hive.box<User>('userBox').put(
        'currentUser',
        User(id: '1', name: 'Owner', email: 'o@test.com', isListed: false),
      );

      final item = Item(
        id: 1,
        ownerId: '1',
        title: 'Del',
        category: ItemCategory.books,
      );
      final service = FakeItemService([item]);

      await tester.pumpWidget(
        MaterialApp(home: ItemDetailPage(item: item, service: service)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('deleteItem')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(service.deletedId, 1);
    });
  });
}
