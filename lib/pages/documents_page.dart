import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/documents_providers.dart';
import '../services/document_service.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';

class DocumentsPage extends StatelessWidget {
  final DocumentService? service;
  const DocumentsPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _DocumentsBody();
    }
    return ProviderScope(
      overrides: [documentServiceProvider.overrideWithValue(service!)],
      child: const _DocumentsBody(),
    );
  }
}

class _DocumentsBody extends ConsumerWidget {
  const _DocumentsBody();

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final file = File(path);
    try {
      await ref.read(documentServiceProvider).uploadDocument(file);
      ref.invalidate(documentsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _download(BuildContext context, WidgetRef ref, Document doc)
      async {
    final bytes =
        await ref.read(documentServiceProvider).downloadDocument(doc.url);
    final fileName = doc.fileName.split('/').last;
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;
    final out = File('$dir/$fileName');
    await out.writeAsBytes(bytes);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Saved to $dir')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final docsAsync = ref.watch(documentsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: AsyncStateView<List<Document>>(
        value: docsAsync,
        errorTitle: AppLocalizations.of(context).errorDocuments,
        onRetry: () => ref.invalidate(documentsProvider),
        isEmpty: (documents) => documents.isEmpty,
        empty: EmptyState(
          icon: Icons.description_outlined,
          title: AppLocalizations.of(context).emptyDocuments,
          subtitle: AppLocalizations.of(context).emptyDocumentsSubtitle,
        ),
        data: (documents) => ListView.separated(
          itemCount: documents.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final doc = documents[i];
            return ListTile(
              title: Text(doc.fileName),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _download(context, ref, doc),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUpload(context, ref),
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
