import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        errorTitle: AppLocalizations.of(context).errorClubs,
        onRetry: () => ref.invalidate(clubsProvider),
        isEmpty: (clubs) => clubs.isEmpty,
        empty: EmptyState(
          icon: Icons.groups_outlined,
          title: AppLocalizations.of(context).emptyClubs,
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
