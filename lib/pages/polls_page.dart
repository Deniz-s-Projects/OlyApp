import 'package:flutter/material.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/polls_providers.dart';
import '../services/poll_service.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';

class PollsPage extends StatelessWidget {
  final PollService? service;
  const PollsPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _PollsBody();
    }
    return ProviderScope(
      overrides: [pollServiceProvider.overrideWithValue(service!)],
      child: const _PollsBody(),
    );
  }
}

class _PollsBody extends ConsumerWidget {
  const _PollsBody();

  Future<void> _vote(WidgetRef ref, BuildContext context, Poll poll, int index)
      async {
    if (poll.id == null) return;
    try {
      await ref.read(pollServiceProvider).vote(poll.id!, index);
      ref.invalidate(pollsProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit vote')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = ref.watch(pollsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(pollsProvider),
      child: AsyncStateView<List<Poll>>(
        value: pollsAsync,
        errorTitle: AppLocalizations.of(context).errorPolls,
        onRetry: () => ref.invalidate(pollsProvider),
        isEmpty: (polls) => polls.isEmpty,
        empty: EmptyState(
          icon: Icons.poll_outlined,
          title: AppLocalizations.of(context).emptyPolls,
        ),
        data: (polls) => ListView.builder(
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poll.question,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < poll.options.length; i++)
                      ListTile(
                        title: Text(
                          '${poll.options[i]} (${poll.counts.length > i ? poll.counts[i] : 0})',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _vote(ref, context, poll, i),
                          child: const Text('Vote'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
