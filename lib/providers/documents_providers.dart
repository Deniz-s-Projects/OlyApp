import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/document_service.dart';

final documentServiceProvider =
    Provider<DocumentService>((ref) => DocumentService());

final documentsProvider = FutureProvider<List<Document>>(
  (ref) async {
    ref.keepAlive();
    final service = ref.watch(documentServiceProvider);
    return service.fetchDocuments();
  },
  dependencies: [documentServiceProvider],
);
