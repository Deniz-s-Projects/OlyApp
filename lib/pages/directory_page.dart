import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/directory_providers.dart';
import '../services/directory_service.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';
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
    final usersAsync = ref.watch(directoryUsersProvider);

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
              child: AsyncStateView<List<User>>(
                value: usersAsync,
                errorTitle: AppLocalizations.of(context).errorDirectory,
                onRetry: () => ref.invalidate(directoryUsersProvider),
                isEmpty: (users) => users.isEmpty,
                empty: EmptyState(
                  icon: Icons.people_outline,
                  title: AppLocalizations.of(context).emptyDirectory,
                ),
                data: (users) => ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: user.avatarUrl != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(user.avatarUrl!),
                            )
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: () {
                        if (user.id == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserChatPage(user: user),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
