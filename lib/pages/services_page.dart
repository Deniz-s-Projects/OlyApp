import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../services/service_list_service.dart';
import '../utils/user_helpers.dart';
import 'post_service_listing_page.dart';
import 'service_detail_page.dart';

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

  Future<void> _openForm([ServiceListing? listing]) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PostServiceListingPage(listing: listing, service: _service),
      ),
    );
    if (created == true) _load();
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
                    onTap: listing.userId == currentUserId()
                        ? () => _openForm(listing)
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailPage(
                                  listing: listing,
                                  service: _service,
                                ),
                              ),
                            ),
                    title: Text(listing.title),
                    subtitle: Text(listing.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (listing.ratings.isNotEmpty) ...[
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(listing.averageRating.toStringAsFixed(1)),
                          const SizedBox(width: 8),
                        ],
                        if (listing.contact != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(listing.contact!),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: listing.contact!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Contact copied'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
