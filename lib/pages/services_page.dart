import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/service_listings_providers.dart';
import '../services/service_list_service.dart';
import '../utils/user_helpers.dart';
import 'post_service_listing_page.dart';
import 'service_detail_page.dart';

class ServicesPage extends StatelessWidget {
  final ServiceListService? service;
  const ServicesPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) return const _ServicesBody();
    return ProviderScope(
      overrides: [serviceListServiceProvider.overrideWithValue(service!)],
      child: const _ServicesBody(),
    );
  }
}

class _ServicesBody extends ConsumerWidget {
  const _ServicesBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final listings = ref.watch(serviceListingsProvider).valueOrNull ??
        const <ServiceListing>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(serviceListingsProvider),
        child: listings.isEmpty
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
                itemCount: listings.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  return ListTile(
                    onTap: listing.userId == currentUserId()
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PostServiceListingPage(listing: listing),
                              ),
                            )
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ServiceDetailPage(listing: listing),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PostServiceListingPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
