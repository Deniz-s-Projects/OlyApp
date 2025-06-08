import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/gallery_service.dart';

class GalleryPage extends StatefulWidget {
  final GalleryService? service;
  const GalleryPage({super.key, this.service});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final GalleryService _service;
  List<GalleryImage> _images = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? GalleryService();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final imgs = await _service.fetchImages();
      if (mounted) setState(() => _images = imgs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _view(GalleryImage img) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FullScreenImage(url: img.url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Gallery'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
          ? const Center(child: Text('No images uploaded.'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _images.length,
              itemBuilder: (ctx, i) {
                final img = _images[i];
                return GestureDetector(
                  onTap: () => _view(img),
                  child: Image.network(
                    img.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: cs.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            child: Image.network(
              url,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
