import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/map_pin.dart';
import 'package:oly_app/pages/map_page.dart';
import 'package:oly_app/services/map_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FakeMapService extends MapService {
  final List<MapPin> pins;
  FakeMapService(this.pins);
  @override
  Future<List<MapPin>> fetchPins() async => pins;
}

class RouteMapService extends FakeMapService {
  bool called = false;
  RouteMapService(super.pins);

  @override
  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    called = true;
    return [start, end];
  }
}

void main() {
  int markerCount(WidgetTester tester) {
    final layer = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
    return layer.markers.length;
  }

  testWidgets('Map loads and displays pins', (tester) async {
    final service = FakeMapService([
      MapPin(
        id: '1',
        title: 'Test',
        lat: 0,
        lon: 0,
        category: MapPinCategory.building,
      ),
      MapPin(
        id: '2',
        title: 'Another',
        lat: 1,
        lon: 1,
        category: MapPinCategory.venue,
      ),
      MapPin(
        id: '3',
        title: 'Playground',
        lat: 2,
        lon: 2,
        category: MapPinCategory.recreation,
      ),
      MapPin(
        id: '4',
        title: 'Cafe',
        lat: 3,
        lon: 3,
        category: MapPinCategory.food,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: MapPage(service: service, loadTiles: false)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(markerCount(tester), 4);
  });

  testWidgets('Search text or category filters pins', (tester) async {
    final service = FakeMapService([
      MapPin(
        id: '1',
        title: 'Dorm',
        lat: 0,
        lon: 0,
        category: MapPinCategory.building,
      ),
      MapPin(
        id: '2',
        title: 'Cafe',
        lat: 1,
        lon: 1,
        category: MapPinCategory.food,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: MapPage(service: service, loadTiles: false)),
    );
    await tester.pumpAndSettle();

    expect(markerCount(tester), 2);

    await tester.enterText(find.byType(TextField), 'cafe');
    await tester.pumpAndSettle();
    expect(markerCount(tester), 1);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(markerCount(tester), 1); // only building pin remains
  });

  testWidgets('Provided route draws polyline', (tester) async {
    final service = FakeMapService([]);
    final route = [const LatLng(0, 0), const LatLng(1, 1)];

    await tester.pumpWidget(
      MaterialApp(
        home: MapPage(service: service, loadTiles: false, route: route),
      ),
    );
    await tester.pumpAndSettle();

    final polyFinder = find.byType(PolylineLayer);
    expect(polyFinder, findsOneWidget);
    final layer = tester.widget<PolylineLayer>(polyFinder);
    expect(layer.polylines.first.points, route);
  });
}
