import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_pin.dart';
import '../services/map_service.dart';

class MapPage extends StatefulWidget {
  final MapService? service;
  final bool loadTiles;
  const MapPage({super.key, this.service, this.loadTiles = true});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapService _service;
  List<MapPin> _pins = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MapService();
    _loadPins();
  }

  Future<void> _loadPins() async {
    final pins = await _service.fetchPins();
    setState(() => _pins = pins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(48.1740, 11.5475),
          initialZoom: 16,
        ),
        children: [
          if (widget.loadTiles)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.olyapp',
            ),
          MarkerLayer(
            markers: _pins
                .map(
                  (p) => Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(p.lat, p.lon),
                    child: Icon(
                      Icons.location_pin,
                      color: _colorFor(p.type),
                      size: 32,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'building':
        return Colors.blue;
      case 'venue':
        return Colors.red;
      case 'amenity':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}
