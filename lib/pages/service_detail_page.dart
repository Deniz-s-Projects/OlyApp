import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/service_listings_providers.dart';
import '../services/service_list_service.dart';
import '../utils/user_helpers.dart';

class ServiceDetailPage extends ConsumerStatefulWidget {
  final ServiceListing listing;
  final ServiceListService? service;

  const ServiceDetailPage({super.key, required this.listing, this.service});

  @override
  ConsumerState<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends ConsumerState<ServiceDetailPage> {
  late ServiceListing _listing = widget.listing;
  late List<ServiceRating> _ratings = widget.listing.ratings;
  final _ratingCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();

  ServiceListService _resolveService() {
    final ServiceListService service =
        widget.service ?? ref.read(serviceListServiceProvider);
    return service;
  }

  @override
  void initState() {
    super.initState();
    // Fire the initial fresh fetch after the first frame so ref is usable.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRatings());
  }

  Future<void> _loadRatings() async {
    if (_listing.id == null) return;
    final list = await _resolveService().fetchRatings(_listing.id!);
    if (mounted) setState(() => _ratings = list);
  }

  Future<void> _submitRating() async {
    if (_listing.id == null) return;
    final rating = int.tryParse(_ratingCtrl.text) ?? 0;
    await _resolveService().submitRating(
      _listing.id!,
      rating,
      review: _reviewCtrl.text,
    );
    if (!mounted) return;
    _ratingCtrl.clear();
    _reviewCtrl.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Rating submitted')));
    await _loadRatings();
    if (mounted) ref.invalidate(serviceListingsProvider);
  }

  @override
  void dispose() {
    _ratingCtrl.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = currentUserId() == _listing.userId;
    return Scaffold(
      appBar: AppBar(title: Text(_listing.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_listing.description),
            const SizedBox(height: 12),
            if (_listing.contact != null)
              Row(
                children: [
                  const Text('Contact: '),
                  Text(_listing.contact!),
                ],
              ),
            const SizedBox(height: 12),
            if (_ratings.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(_listing.averageRating.toStringAsFixed(1)),
                ],
              )
            else
              const Text('No ratings yet'),
            if (!isOwner) ...[
              const SizedBox(height: 24),
              TextField(
                controller: _ratingCtrl,
                decoration: const InputDecoration(labelText: 'Rating (1-5)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
              ),
              TextField(
                controller: _reviewCtrl,
                decoration: const InputDecoration(labelText: 'Review'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitRating,
                child: const Text('Submit Rating'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
