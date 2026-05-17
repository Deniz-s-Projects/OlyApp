import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_pin.dart';
import '../providers/map_providers.dart';
import '../services/map_service.dart';

class MapPage extends StatelessWidget {
  final MapService? service;
  final bool loadTiles;
  final List<LatLng>? route;
  final LatLng? center;
  const MapPage({
    super.key,
    this.service,
    this.loadTiles = true,
    this.route,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final body = _MapBody(loadTiles: loadTiles, route: route, center: center);
    if (service == null) return body;
    return ProviderScope(
      overrides: [mapServiceProvider.overrideWithValue(service!)],
      child: body,
    );
  }
}

class _MapBody extends ConsumerStatefulWidget {
  final bool loadTiles;
  final List<LatLng>? route;
  final LatLng? center;
  const _MapBody({
    required this.loadTiles,
    required this.route,
    required this.center,
  });

  @override
  ConsumerState<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends ConsumerState<_MapBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  Set<MapPinCategory> _selectedCats = {};
  List<MapPin> _selectedPins = [];
  List<LatLng>? _route;

  @override
  void initState() {
    super.initState();
    _selectedCats = Set.from(MapPinCategory.values);
    _route = widget.route;
  }

  List<MapPin> _filteredPins(List<MapPin> all) {
    final query = _searchCtrl.text.toLowerCase();
    return all
        .where((p) =>
            p.title.toLowerCase().contains(query) &&
            _selectedCats.contains(p.category))
        .toList();
  }

  Future<void> _onPinTap(MapPin pin) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_location),
              title: const Text('Add to route'),
              onTap: () => Navigator.pop(ctx, 'add'),
            ),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Route from my location'),
              onTap: () => Navigator.pop(ctx, 'from'),
            ),
          ],
        ),
      ),
    );

    if (result == 'add') {
      setState(() {
        if (_selectedPins.contains(pin)) {
          _selectedPins.remove(pin);
        } else {
          _selectedPins.add(pin);
          if (_selectedPins.length > 2) {
            _selectedPins.removeAt(0);
          }
        }
      });
    } else if (result == 'from') {
      setState(() {
        _selectedPins = [pin];
      });
    }

    await _updateRoute();
  }

  Future<void> _updateRoute() async {
    final service = ref.read(mapServiceProvider);
    if (_selectedPins.length == 2) {
      final start = LatLng(_selectedPins[0].lat, _selectedPins[0].lon);
      final end = LatLng(_selectedPins[1].lat, _selectedPins[1].lon);
      final r = await service.fetchRoute(start, end);
      if (mounted) setState(() => _route = r);
    } else if (_selectedPins.length == 1) {
      try {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          if (mounted) setState(() => _route = null);
          return;
        }
        final pos = await Geolocator.getCurrentPosition();
        final start = LatLng(pos.latitude, pos.longitude);
        final end = LatLng(_selectedPins[0].lat, _selectedPins[0].lon);
        final r = await service.fetchRoute(start, end);
        if (mounted) setState(() => _route = r);
      } catch (_) {
        if (mounted) setState(() => _route = null);
      }
    } else {
      if (mounted) setState(() => _route = null);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPins =
        ref.watch(mapPinsProvider).valueOrNull ?? const <MapPin>[];
    final visiblePins = _filteredPins(allPins);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.invalidate(mapPinsProvider),
        child: const Icon(Icons.refresh),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.center ?? const LatLng(48.1740, 11.5475),
              initialZoom: 16,
            ),
            children: [
              if (widget.loadTiles)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.olyapp',
                  tileProvider: _safeProvider(),
                ),
              MarkerLayer(
                markers: visiblePins
                    .map(
                      (p) => Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(p.lat, p.lon),
                        child: GestureDetector(
                          key: ValueKey(p.id),
                          onTap: () => _onPinTap(p),
                          child: Semantics(
                            label: p.id,
                            child: Icon(
                              Icons.location_pin,
                              color: _colorFor(p.category),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (_route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route!,
                      strokeWidth: 4,
                      color: Colors.orange,
                    ),
                  ],
                ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search…',
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: MapPinCategory.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = MapPinCategory.values[i];
                        final selected = _selectedCats.contains(cat);
                        return FilterChip(
                          label: Text(_catName(cat)),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              if (selected) {
                                _selectedCats.remove(cat);
                              } else {
                                _selectedCats.add(cat);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap a pin and choose "Route from my location" to start a route, or tap two pins to route between them.',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(MapPinCategory category) {
    switch (category) {
      case MapPinCategory.building:
        return Colors.blue;
      case MapPinCategory.venue:
        return Colors.red;
      case MapPinCategory.amenity:
        return Colors.green;
      case MapPinCategory.recreation:
        return Colors.orange;
      case MapPinCategory.food:
        return Colors.brown;
    }
  }

  String _catName(MapPinCategory category) {
    final name = category.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  TileProvider _safeProvider() {
    try {
      return FMTCTileProvider(
        stores: {'mapTiles': BrowseStoreStrategy.readUpdateCreate},
      );
    } catch (_) {
      return NetworkTileProvider();
    }
  }
}
