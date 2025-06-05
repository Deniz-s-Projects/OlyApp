import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_pin.dart';
import '../services/map_service.dart';

class MapPage extends StatefulWidget {
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
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapService _service;
  List<MapPin> _allPins = [];
  List<MapPin> _visiblePins = [];
  final TextEditingController _searchCtrl = TextEditingController();
  Set<MapPinCategory> _selectedCats = {};
  List<MapPin> _selectedPins = [];
  List<LatLng>? _route;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MapService();
    _selectedCats = Set.from(MapPinCategory.values);
    _route = widget.route;
    _loadPins();
  }

  Future<void> _loadPins() async {
    final pins = await _service.fetchPins();
    setState(() {
      _allPins = pins;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _visiblePins =
          _allPins.where((p) {
            final matchesText = p.title.toLowerCase().contains(query);
            final matchesCat = _selectedCats.contains(p.category);
            return matchesText && matchesCat;
          }).toList();
    });
  }

  Future<void> _onPinTap(MapPin pin) async {
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
    await _updateRoute();
  }

  Future<void> _updateRoute() async {
    if (_selectedPins.length == 2) {
      final start = LatLng(_selectedPins[0].lat, _selectedPins[0].lon);
      final end = LatLng(_selectedPins[1].lat, _selectedPins[1].lon);
      final r = await _service.fetchRoute(start, end);
      setState(() => _route = r);
    } else {
      setState(() => _route = null);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPins,
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
                markers:
                    _visiblePins
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
                    onChanged: (_) => _applyFilters(),
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
                              _applyFilters();
                            });
                          },
                        );
                      },
                    ),
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
