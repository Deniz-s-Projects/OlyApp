import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/item_service.dart';
import '../utils/user_helpers.dart';

class PostItemPage extends StatefulWidget {
  final Item? item;
  final ItemService? service;

  const PostItemPage({super.key, this.item, this.service});

  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _imageCtrl;
  XFile? _imageFile;
  late ItemCategory _category;
  late final ItemService _service;
  bool _submitting = false;

  bool get _editing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ItemService();
    final item = widget.item;
    _titleCtrl = TextEditingController(text: item?.title ?? '');
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _priceCtrl = TextEditingController(text: item?.price?.toString() ?? '');
    _imageCtrl = TextEditingController(text: item?.imageUrl ?? '');
    _category = item?.category ?? ItemCategory.other;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null) {
      setState(() => _imageFile = file);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final priceText = _priceCtrl.text.trim();
      final price = priceText.isNotEmpty ? double.tryParse(priceText) : null;
      final imagePath =
          _imageFile == null && _imageCtrl.text.trim().isNotEmpty
              ? _imageCtrl.text.trim()
              : null;
      final editing = _editing;
      final item = Item(
        id: editing ? widget.item!.id : null,
        ownerId: editing ? widget.item!.ownerId : currentUserId(),
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        imageUrl: imagePath,
        price: price,
        isFree: price == null || price == 0,
        category: _category,
      );
      if (editing) {
        await _service.updateItem(item);
      } else {
        await _service.createItem(
          item,
          imageFile: _imageFile != null ? File(_imageFile!.path) : null,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(editing ? 'Item updated!' : 'Item posted!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Item' : 'Post Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ItemCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    ItemCategory.values.map((cat) {
                      String label;
                      switch (cat) {
                        case ItemCategory.furniture:
                          label = 'Furniture';
                        case ItemCategory.books:
                          label = 'Books';
                        case ItemCategory.electronics:
                          label = 'Electronics';
                        case ItemCategory.appliances:
                          label = 'Appliances';
                        case ItemCategory.clothing:
                          label = 'Clothing';
                        default:
                          label = 'Other';
                      }
                      return DropdownMenuItem(value: cat, child: Text(label));
                    }).toList(),
                onChanged:
                    (val) =>
                        setState(() => _category = val ?? ItemCategory.other),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ],
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 12),
                Image.file(File(_imageFile!.path), height: 150),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Text(
                  _submitting
                      ? (_editing ? 'Updating…' : 'Posting…')
                      : _editing
                      ? 'Update Item'
                      : 'Post Item',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
