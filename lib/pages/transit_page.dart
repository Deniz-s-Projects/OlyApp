import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/transit_service.dart';

class TransitPage extends StatefulWidget {
  final TransitService? service;
  const TransitPage({super.key, this.service});

  @override
  State<TransitPage> createState() => _TransitPageState();
}

class _TransitPageState extends State<TransitPage> {
  late final TransitService _service;
  final TextEditingController _searchCtrl = TextEditingController();
  List<TransitStop> _searchResults = [];
  List<TransitStop> _pinned = [];
  TransitStop? _selected;
  List<TransitDeparture> _departures = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TransitService();
    _loadPinned();
  }

  Future<void> _loadPinned() async {
    final list = await _service.loadPinnedStops();
    if (!mounted) return;
    setState(() => _pinned = list);
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final results = await _service.searchStops(q);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Search failed')));
    }
  }

  Future<void> _selectStop(TransitStop stop) async {
    try {
      final deps = await _service.fetchDepartures(stop.id);
      if (!mounted) return;
      setState(() {
        _selected = stop;
        _departures = deps;
        _searchResults = [];
        _searchCtrl.text = stop.name;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to load')));
    }
  }

  Future<void> _togglePin(TransitStop stop) async {
    final exists = _pinned.any((p) => p.id == stop.id);
    if (exists) {
      await _service.unpinStop(stop.id);
    } else {
      await _service.pinStop(stop);
    }
    await _loadPinned();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(labelText: 'Search Stop'),
              onChanged: _search,
            ),
          ),
          if (_pinned.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _pinned
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ActionChip(
                          label: Text(s.name),
                          onPressed: () => _selectStop(s),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView(
                children: _searchResults
                    .map(
                      (s) => ListTile(
                        title: Text(s.name),
                        trailing: IconButton(
                          icon: Icon(_pinned.any((p) => p.id == s.id)
                              ? Icons.star
                              : Icons.star_border),
                          onPressed: () => _togglePin(s),
                        ),
                        onTap: () => _selectStop(s),
                      ),
                    )
                    .toList(),
              ),
            )
          else if (_selected != null)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Departures from ${_selected!.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: _departures
                          .map(
                            (d) => ListTile(
                              title: Text('${d.line} → ${d.destination}'),
                              trailing: Text(
                                  '${d.time.hour.toString().padLeft(2, '0')}:${d.time.minute.toString().padLeft(2, '0')}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
