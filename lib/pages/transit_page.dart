import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/transit_providers.dart';
import '../services/transit_service.dart';

class TransitPage extends StatelessWidget {
  final TransitService? service;
  const TransitPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) return const _TransitBody();
    return ProviderScope(
      overrides: [transitServiceProvider.overrideWithValue(service!)],
      child: const _TransitBody(),
    );
  }
}

class _TransitBody extends ConsumerStatefulWidget {
  const _TransitBody();

  @override
  ConsumerState<_TransitBody> createState() => _TransitBodyState();
}

class _TransitBodyState extends ConsumerState<_TransitBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<TransitStop> _searchResults = [];
  TransitStop? _selected;
  List<TransitDeparture> _departures = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final results = await ref.read(transitServiceProvider).searchStops(q);
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
      final deps =
          await ref.read(transitServiceProvider).fetchDepartures(stop.id);
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

  Future<void> _togglePin(TransitStop stop, List<TransitStop> pinned) async {
    final exists = pinned.any((p) => p.id == stop.id);
    final service = ref.read(transitServiceProvider);
    if (exists) {
      await service.unpinStop(stop.id);
    } else {
      await service.pinStop(stop);
    }
    ref.invalidate(pinnedStopsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final pinned =
        ref.watch(pinnedStopsProvider).valueOrNull ?? const <TransitStop>[];
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
          if (pinned.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: pinned
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
                          icon: Icon(pinned.any((p) => p.id == s.id)
                              ? Icons.star
                              : Icons.star_border),
                          onPressed: () => _togglePin(s, pinned),
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
