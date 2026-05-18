import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../providers/lost_found_providers.dart';
import '../services/lost_found_service.dart';
import '../utils/user_helpers.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';
import 'lost_found_detail_page.dart';

class LostFoundPage extends StatelessWidget {
  final LostFoundService? service;
  const LostFoundPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _LostFoundBody();
    }
    return ProviderScope(
      overrides: [lostFoundServiceProvider.overrideWithValue(service!)],
      child: const _LostFoundBody(),
    );
  }
}

class _LostFoundBody extends ConsumerStatefulWidget {
  const _LostFoundBody();

  @override
  ConsumerState<_LostFoundBody> createState() => _LostFoundBodyState();
}

class _LostFoundBodyState extends ConsumerState<_LostFoundBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  XFile? _imageFile;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null) setState(() => _imageFile = file);
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    await ref.read(lostFoundServiceProvider).createItem(
          LostItem(
            ownerId: currentUserId(),
            title: title,
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
          ),
          imageFile: _imageFile != null ? File(_imageFile!.path) : null,
        );
    if (!mounted) return;
    _titleCtrl.clear();
    _descCtrl.clear();
    setState(() => _imageFile = null);
    ref.invalidate(lostFoundItemsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filters = ref.watch(lostFoundFiltersProvider);
    final filtersNotifier = ref.read(lostFoundFiltersProvider.notifier);
    final itemsAsync = ref.watch(lostFoundItemsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search…',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () =>
                          ref.invalidate(lostFoundItemsProvider),
                    ),
                  ),
                  onChanged: filtersNotifier.setSearch,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: filters.type,
                        isExpanded: true,
                        onChanged: (val) {
                          if (val == null) return;
                          filtersNotifier.setType(val);
                        },
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All Types')),
                          DropdownMenuItem(
                              value: 'lost', child: Text('Lost')),
                          DropdownMenuItem(
                              value: 'found', child: Text('Found')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: filters.resolved,
                        isExpanded: true,
                        onChanged: (val) {
                          if (val == null) return;
                          filtersNotifier.setResolved(val);
                        },
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('Any Status')),
                          DropdownMenuItem(
                              value: 'false', child: Text('Unresolved')),
                          DropdownMenuItem(
                              value: 'true', child: Text('Resolved')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncStateView<List<LostItem>>(
              value: itemsAsync,
              errorTitle: AppLocalizations.of(context).errorLostFound,
              onRetry: () => ref.invalidate(lostFoundItemsProvider),
              isEmpty: (items) => items.isEmpty,
              empty: EmptyState(
                icon: Icons.help_outline,
                title: AppLocalizations.of(context).emptyLostFound,
                subtitle: AppLocalizations.of(context).emptyLostFoundSubtitle,
              ),
              data: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    title: Text(item.title),
                    subtitle: item.description != null
                        ? Text(item.description!)
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final changed = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LostFoundDetailPage(
                            item: item,
                            service: ref.read(lostFoundServiceProvider),
                          ),
                        ),
                      );
                      if (changed == true) {
                        ref.invalidate(lostFoundItemsProvider);
                      }
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
                  Image.file(File(_imageFile!.path), height: 150),
                ],
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _submit, child: const Text('Post')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
