import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/models.dart';
import '../services/document_service.dart';

class DocumentsPage extends StatefulWidget {
  final DocumentService? service;
  const DocumentsPage({super.key, this.service});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late final DocumentService _service;
  List<Document> _documents = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? DocumentService();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _service.fetchDocuments();
      if (mounted) setState(() => _documents = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final file = File(path);
    try {
      final doc = await _service.uploadDocument(file);
      if (mounted) setState(() => _documents.add(doc));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? const Center(child: Text('No documents uploaded.'))
              : ListView.separated(
                  itemCount: _documents.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final doc = _documents[i];
                    return ListTile(
                      title: Text(doc.fileName),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          final bytes = await _service.downloadDocument(doc.url);
                          final fileName = doc.fileName.split('/').last;
                          final dir = await FilePicker.platform.getDirectoryPath();
                          if (dir == null) return;
                          final out = File('$dir/$fileName');
                          await out.writeAsBytes(bytes);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Saved to $dir')));
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUpload,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
