import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../providers/maintenance_providers.dart';
import '../services/maintenance_service.dart';
import '../utils/user_helpers.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';
import 'maintenance_chat_page.dart';

class MaintenancePage extends StatelessWidget {
  /// Optional service override. Mainly used by widget tests; production
  /// callers rely on the top-level [ProviderScope] in main.dart.
  final MaintenanceService? service;
  const MaintenancePage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _MaintenanceBody();
    }
    return ProviderScope(
      overrides: [maintenanceServiceProvider.overrideWithValue(service!)],
      child: const _MaintenanceBody(),
    );
  }
}

class _MaintenanceBody extends ConsumerStatefulWidget {
  const _MaintenanceBody();

  @override
  ConsumerState<_MaintenanceBody> createState() => _MaintenanceBodyState();
}

class _MaintenanceBodyState extends ConsumerState<_MaintenanceBody> {
  int _selectedTab = 0;
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null) {
      setState(() => _imageFile = file);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TabButton(
                  label: 'New Request',
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _TabButton(
                  label: 'Conversations',
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _selectedTab == 0 ? _buildForm(context) : _buildConversations(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description'),
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
            onPressed: () async {
              final subject = _subjectController.text.trim();
              final desc = _descriptionController.text.trim();
              if (subject.isEmpty || desc.isEmpty) return;
              final service = ref.read(maintenanceServiceProvider);
              await service.createRequest(
                MaintenanceRequest(
                  userId: currentUserId(),
                  subject: subject,
                  description: desc,
                ),
                imageFile: _imageFile != null ? File(_imageFile!.path) : null,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request submitted!')),
              );
              _subjectController.clear();
              _descriptionController.clear();
              setState(() => _imageFile = null);
              ref.invalidate(maintenanceRequestsProvider);
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversations() {
    final ticketsAsync = ref.watch(maintenanceRequestsProvider);
    return AsyncStateView<List<MaintenanceRequest>>(
      value: ticketsAsync,
      errorTitle: AppLocalizations.of(context).errorMaintenance,
      onRetry: () => ref.invalidate(maintenanceRequestsProvider),
      isEmpty: (tickets) => tickets.isEmpty,
      empty: EmptyState(
        icon: Icons.handyman_outlined,
        title: AppLocalizations.of(context).emptyMaintenance,
        subtitle: AppLocalizations.of(context).emptyMaintenanceSubtitle,
      ),
      data: (tickets) => ListView.separated(
        itemCount: tickets.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return ListTile(
            title: Text(ticket.subject),
            subtitle: Text('Status: ${ticket.status}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MaintenanceChatPage(request: ticket),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
