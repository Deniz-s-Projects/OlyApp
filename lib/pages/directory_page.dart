import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/directory_providers.dart';
import '../services/directory_service.dart';
import 'user_chat_page.dart';

class DirectoryPage extends StatelessWidget {
  final DirectoryService? service;
  const DirectoryPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _DirectoryBody();
    }
    return ProviderScope(
      overrides: [directoryServiceProvider.overrideWithValue(service!)],
      child: const _DirectoryBody(),
    );
  }
}

class _DirectoryBody extends ConsumerStatefulWidget {
  const _DirectoryBody();

  @override
  ConsumerState<_DirectoryBody> createState() => _DirectoryBodyState();
}

class _DirectoryBodyState extends ConsumerState<_DirectoryBody> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<User>>>(directoryUsersProvider, (prev, next) {
      // Only surface errors when no users are shown (matches prior behavior).
      if (next.hasError && !next.isLoading) {
        final fallback = (prev?.valueOrNull ?? const <User>[]);
        if (fallback.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load users')),
          );
        }
      }
    });

    final usersAsync = ref.watch(directoryUsersProvider);
    final users = usersAsync.valueOrNull ?? const <User>[];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search residents…',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(directoryUsersProvider),
                ),
              ),
              onChanged: (value) =>
                  ref.read(directorySearchProvider.notifier).set(value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: usersAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                      ? const Center(child: Text('No residents found.'))
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: user.avatarUrl != null
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.avatarUrl!),
                                    )
                                  : const CircleAvatar(
                                      child: Icon(Icons.person)),
                              title: Text(user.name),
                              subtitle: Text(user.email),
                              onTap: () {
                                if (user.id == null) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        UserChatPage(user: user),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
