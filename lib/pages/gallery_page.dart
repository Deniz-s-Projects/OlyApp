import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/gallery_providers.dart';
import '../services/gallery_service.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';

class GalleryPage extends StatelessWidget {
  final GalleryService? service;
  const GalleryPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _GalleryBody();
    }
    return ProviderScope(
      overrides: [galleryServiceProvider.overrideWithValue(service!)],
      child: const _GalleryBody(),
    );
  }
}

class _GalleryBody extends ConsumerWidget {
  const _GalleryBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final imagesAsync = ref.watch(galleryImagesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Gallery'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: AsyncStateView<List<GalleryImage>>(
        value: imagesAsync,
        errorTitle: AppLocalizations.of(context).errorGallery,
        onRetry: () => ref.invalidate(galleryImagesProvider),
        isEmpty: (images) => images.isEmpty,
        empty: EmptyState(
          icon: Icons.photo_library_outlined,
          title: AppLocalizations.of(context).emptyGallery,
          subtitle: AppLocalizations.of(context).emptyGallerySubtitle,
        ),
        data: (images) => GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: images.length,
          itemBuilder: (ctx, i) {
            final img = images[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _FullScreenImage(url: img.url),
                ),
              ),
              child: Image.network(
                img.url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
