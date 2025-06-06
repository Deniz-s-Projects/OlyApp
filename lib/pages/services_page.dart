import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/service_list_service.dart';

class ServicesPage extends StatefulWidget {
  final ServiceListService? service;
  const ServicesPage({super.key, this.service});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late final ServiceListService _service;
  List<ServiceListing> _listings = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ServiceListService();
    _load();
  }

  Future<void> _load() async {
    final listings = await _service.fetchListings();
    if (!mounted) return;
    setState(() => _listings = listings);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _listings.isEmpty
            ? ListView(
                children: const [
                  SizedBox(
                    height: 200,
                    child: Center(child: Text('No services')),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _listings.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final listing = _listings[index];
                  return ListTile(
                    title: Text(listing.title),
                    subtitle: Text(listing.description),
                    trailing: listing.contact != null
                        ? Text(listing.contact!)
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
