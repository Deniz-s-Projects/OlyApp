import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/service_list_service.dart';
import '../utils/user_helpers.dart';

class ServiceDetailPage extends StatefulWidget {
  final ServiceListing listing;
  final ServiceListService? service;

  const ServiceDetailPage({super.key, required this.listing, this.service});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  late ServiceListing _listing;
  late ServiceListService _service;
  List<ServiceRating> _ratings = [];
  final _ratingCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
    _service = widget.service ?? ServiceListService();
    _ratings = _listing.ratings;
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    if (_listing.id == null) return;
    final list = await _service.fetchRatings(_listing.id!);
    if (mounted) setState(() => _ratings = list);
  }

  Future<void> _submitRating() async {
    if (_listing.id == null) return;
    final rating = int.tryParse(_ratingCtrl.text) ?? 0;
    await _service.submitRating(
      _listing.id!,
      rating,
      review: _reviewCtrl.text,
    );
    if (!mounted) return;
    _ratingCtrl.clear();
    _reviewCtrl.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Rating submitted')));
    _loadRatings();
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
