import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/clubs_providers.dart';
import '../services/club_service.dart';
import '../widgets/async_state_view.dart';
import '../widgets/empty_state.dart';
import 'club_detail_page.dart';

class ClubsPage extends StatelessWidget {
  final ClubService? service;
  const ClubsPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _ClubsBody();
    }
    return ProviderScope(
      overrides: [clubServiceProvider.overrideWithValue(service!)],
      child: const _ClubsBody(),
    );
  }
}

class _ClubsBody extends ConsumerWidget {
  const _ClubsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(clubsProvider);
    final service = ref.watch(clubServiceProvider);
    return Scaffold(
      body: AsyncStateView<List<Club>>(
        value: clubsAsync,
        errorTitle: 'Failed to load clubs',
        onRetry: () => ref.invalidate(clubsProvider),
        isEmpty: (clubs) => clubs.isEmpty,
        empty: const EmptyState(
          icon: Icons.groups_outlined,
          title: 'No clubs yet',
        ),
        data: (clubs) => ListView.builder(
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];
            return ListTile(
              title: Text(club.name),
              subtitle: Text(club.description ?? ''),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ClubDetailPage(club: club, service: service),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
