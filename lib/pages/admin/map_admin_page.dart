import 'package:flutter/material.dart';
import '../../models/map_pin.dart';
import '../../services/map_service.dart';
import '../../utils/user_helpers.dart';

class MapAdminPage extends StatefulWidget {
  final MapService? service;
  const MapAdminPage({super.key, this.service});

  @override
  State<MapAdminPage> createState() => _MapAdminPageState();
}

class _MapAdminPageState extends State<MapAdminPage> {
  late final MapService _service;
  List<MapPin> _pins = [];

  @override
  void initState() {
    super.initState();
    if (!currentUserIsAdmin()) {
      Future.microtask(() {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin access required')),
        );
      });
    } else {
      _service = widget.service ?? MapService();
      _load();
    }
  }

  Future<void> _load() async {
    final pins = await _service.fetchPins();
    setState(() => _pins = pins);
  }

  Future<void> _addPin() async {
    final pin = await _showPinDialog();
    if (pin != null) {
      await _service.createPin(pin);
      _load();
    }
  }

  Future<void> _editPin(MapPin pin) async {
    final result = await _showPinDialog(pin);
    if (result != null) {
      await _service.updatePin(result);
      _load();
    }
  }

  Future<void> _deletePin(String id) async {
    await _service.deletePin(id);
    _load();
  }

  Future<MapPin?> _showPinDialog([MapPin? pin]) async {
    final idCtrl = TextEditingController(text: pin?.id ?? '');
    final titleCtrl = TextEditingController(text: pin?.title ?? '');
    final latCtrl = TextEditingController(text: pin?.lat.toString() ?? '');
    final lonCtrl = TextEditingController(text: pin?.lon.toString() ?? '');
    MapPinCategory category = pin?.category ?? MapPinCategory.building;
    return showDialog<MapPin>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(pin == null ? 'Add Pin' : 'Edit Pin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idCtrl,
                      decoration: const InputDecoration(labelText: 'ID'),
                    ),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: latCtrl,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: lonCtrl,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButton<MapPinCategory>(
                      value: category,
                      onChanged: (v) => setState(() => category = v!),
                      items: MapPinCategory.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final id = idCtrl.text.trim();
                    final title = titleCtrl.text.trim();
                    final lat = double.tryParse(latCtrl.text) ?? 0;
                    final lon = double.tryParse(lonCtrl.text) ?? 0;
                    if (id.isEmpty || title.isEmpty) return;
                    Navigator.pop(
                      ctx,
                      MapPin(
                        id: id,
                        title: title,
                        lat: lat,
                        lon: lon,
                        category: category,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Map Pins')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPin,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _pins.length,
        itemBuilder: (ctx, i) {
          final p = _pins[i];
          return ListTile(
            title: Text(p.title),
            subtitle: Text('${p.lat}, ${p.lon} (${p.category.name})'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editPin(p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePin(p.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
