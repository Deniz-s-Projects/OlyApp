import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/gallery_service.dart';

final galleryServiceProvider =
    Provider<GalleryService>((ref) => GalleryService());

final galleryImagesProvider = FutureProvider<List<GalleryImage>>(
  (ref) async {
    ref.keepAlive();
    final service = ref.watch(galleryServiceProvider);
    return service.fetchImages();
  },
  dependencies: [galleryServiceProvider],
);
