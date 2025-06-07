import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/gallery_service.dart';
import '../../utils/user_helpers.dart';

class GalleryAdminPage extends StatefulWidget {
  const GalleryAdminPage({super.key});

  @override
  State<GalleryAdminPage> createState() => _GalleryAdminPageState();
}

class _GalleryAdminPageState extends State<GalleryAdminPage> {
  final GalleryService _service = GalleryService();
  final ImagePicker _picker = ImagePicker();
  XFile? _file;
  bool _uploading = false;

  Future<void> _pick() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _file = f);
  }

  Future<void> _upload() async {
    if (_file == null) return;
    setState(() => _uploading = true);
    try {
      await _service.uploadImage(File(_file!.path));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Uploaded!')));
        setState(() => _file = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Gallery Image')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_file != null) ...[
              Image.file(File(_file!.path), height: 200),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose Image'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _uploading ? null : _upload,
              child: Text(_uploading ? 'Uploading…' : 'Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
