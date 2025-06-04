import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/map_pin.dart';
import 'package:oly_app/pages/map_page.dart';
import 'package:oly_app/services/map_service.dart';
import 'package:flutter_map/flutter_map.dart';

class FakeMapService extends MapService {
  final List<MapPin> pins;
  FakeMapService(this.pins);
  @override
  Future<List<MapPin>> fetchPins() async => pins;
}

void main() {
  testWidgets('Map loads and displays pins', (tester) async {
    final service = FakeMapService([
      MapPin(id: '1', title: 'Test', lat: 0, lon: 0, type: 'building'),
      MapPin(id: '2', title: 'Another', lat: 1, lon: 1, type: 'venue'),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: MapPage(service: service, loadTiles: false)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(MarkerLayer), findsOneWidget);
  });
}
