import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/item_service.dart';

class PostItemPage extends StatefulWidget {
  const PostItemPage({super.key});

  @override
  State<PostItemPage> createState() => _PostItemPageState();
}

class _PostItemPageState extends State<PostItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  ItemCategory _category = ItemCategory.other;
  final ItemService _service = ItemService();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final priceText = _priceCtrl.text.trim();
      final price = priceText.isNotEmpty ? double.tryParse(priceText) : null;
      final item = Item(
        ownerId: 1,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
        price: price,
        isFree: price == null || price == 0,
        category: _category,
      );
      await _service.createItem(item);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Item posted!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to post: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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
                items: ItemCategory.values.map((cat) {
                  String label;
                    switch (cat) {
                      case ItemCategory.furniture:
                        label = 'Furniture';
                      case ItemCategory.books:
                        label = 'Books';
                      case ItemCategory.electronics:
                        label = 'Electronics';
                      default:
                        label = 'Other';
                    }
                  return DropdownMenuItem(value: cat, child: Text(label));
                }).toList(),
                onChanged: (val) => setState(() => _category = val ?? ItemCategory.other),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(labelText: 'Image URL (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Posting…' : 'Post Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
