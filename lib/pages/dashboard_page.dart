import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/calendar_providers.dart';
import '../providers/maintenance_providers.dart';
import '../providers/user_providers.dart';
import '../theme/tokens.dart';
import 'admin/admin_home_page.dart';
import 'booking_page.dart';
import 'calendar_page.dart';
import 'clubs_page.dart';
import 'create_channel_page.dart';
import 'directory_page.dart';
import 'documents_page.dart';
import 'gallery_page.dart';
import 'group_chat_page.dart';
import 'item_exchange_page.dart';
import 'job_posts/job_posts_page.dart';
import 'lost_found_page.dart';
import 'maintenance_page.dart';
import 'nav_target.dart';
import 'polls_page.dart';
import 'services_page.dart';
import 'study_groups_page.dart';
import 'transit_page.dart';
import 'tutoring_page.dart';
import 'weather_page.dart';
import 'wiki_page.dart';

/// The home tab of the bottom nav. Surfaces a greeting, two live status tiles,
/// and a grouped grid of every feature in the app.
class DashboardPage extends ConsumerWidget {
  final ValueChanged<NavTarget> onNavigate;
  final bool isAdmin;

  /// Test-only overrides passed through from [MainPage]. The dashboard pushes
  /// these instead of constructing fresh pages so widget tests can inject
  /// fake services.
  final CalendarPage? injectedCalendarPage;
  final BookingPage? injectedBookingPage;
  final MaintenancePage? injectedMaintenancePage;
  final ItemExchangePage? injectedItemExchangePage;

  const DashboardPage({
    super.key,
    required this.onNavigate,
    this.isAdmin = false,
    this.injectedCalendarPage,
    this.injectedBookingPage,
    this.injectedMaintenancePage,
    this.injectedItemExchangePage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(currentUserFirstNameProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final maintenanceAsync = ref.watch(maintenanceRequestsProvider);
    final l = AppLocalizations.of(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(eventsProvider);
          ref.invalidate(maintenanceRequestsProvider);
          await Future.wait([
            ref.read(eventsProvider.future),
            ref.read(maintenanceRequestsProvider.future),
          ]);
        },
        // SingleChildScrollView (not ListView) so every section is eagerly
        // realized — keeps widget-tests able to find off-screen tiles via
        // find.text without needing scrollUntilVisible.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _Greeting(firstName: firstName),
            const SizedBox(height: AppSpacing.lg),
            _StatusRow(
              eventsAsync: eventsAsync,
              maintenanceAsync: maintenanceAsync,
              onTapNextEvent: () => onNavigate(NavTarget.calendar),
              onTapMaintenance: () => _push(
                context,
                injectedMaintenancePage ?? const MaintenancePage(),
              ),
            ),
            _DashboardSection(
              title: l.sectionCommunity,
              tiles: [
                _Tile(
                  icon: Icons.campaign,
                  label: l.tileBulletin,
                  onTap: () => onNavigate(NavTarget.bulletin),
                ),
                _Tile(
                  icon: Icons.people,
                  label: l.tileDirectory,
                  onTap: () => _push(context, const DirectoryPage()),
                ),
                _Tile(
                  icon: Icons.group,
                  label: l.tileClubs,
                  onTap: () => _push(context, const ClubsPage()),
                ),
                _Tile(
                  icon: Icons.forum,
                  label: l.tileChannels,
                  onTap: () => _openCreateChannel(context),
                ),
                _Tile(
                  icon: Icons.poll,
                  label: l.tilePolls,
                  onTap: () => _push(context, const PollsPage()),
                ),
                _Tile(
                  icon: Icons.photo_library,
                  label: l.tileGallery,
                  onTap: () => _push(context, const GalleryPage()),
                ),
              ],
            ),
            _DashboardSection(
              title: l.sectionMarketplace,
              tiles: [
                _Tile(
                  icon: Icons.swap_horiz,
                  label: l.tileExchange,
                  onTap: () => _push(
                    context,
                    injectedItemExchangePage ?? const ItemExchangePage(),
                  ),
                ),
                _Tile(
                  icon: Icons.help_outline,
                  label: l.tileLostFound,
                  onTap: () => _push(context, const LostFoundPage()),
                ),
                _Tile(
                  icon: Icons.work_outline,
                  label: l.tileJobs,
                  onTap: () => _push(context, const JobPostsPage()),
                ),
                _Tile(
                  icon: Icons.menu_book_outlined,
                  label: l.tileTutoring,
                  onTap: () => _push(context, const TutoringPage()),
                ),
                _Tile(
                  icon: Icons.miscellaneous_services,
                  label: l.tileServices,
                  onTap: () => _push(context, const ServicesPage()),
                ),
                _Tile(
                  icon: Icons.school,
                  label: l.tileStudyGroups,
                  onTap: () => _push(context, const StudyGroupsPage()),
                ),
              ],
            ),
            _DashboardSection(
              title: l.sectionDaily,
              tiles: [
                _Tile(
                  icon: Icons.build,
                  label: l.tileMaintenance,
                  onTap: () => _push(
                    context,
                    injectedMaintenancePage ?? const MaintenancePage(),
                  ),
                ),
                _Tile(
                  icon: Icons.schedule,
                  label: l.tileBooking,
                  onTap: () => _push(
                    context,
                    injectedBookingPage ?? const BookingPage(),
                  ),
                ),
                _Tile(
                  icon: Icons.directions_bus,
                  label: l.tileTransit,
                  onTap: () => _push(context, const TransitPage()),
                ),
                _Tile(
                  icon: Icons.cloud_outlined,
                  label: l.tileWeather,
                  onTap: () => _push(context, const WeatherPage()),
                ),
                _Tile(
                  icon: Icons.description_outlined,
                  label: l.tileDocuments,
                  onTap: () => _push(context, const DocumentsPage()),
                ),
                _Tile(
                  icon: Icons.menu_book,
                  label: l.tileWiki,
                  onTap: () => _push(context, const WikiPage()),
                ),
              ],
            ),
            if (isAdmin)
              _DashboardSection(
                title: l.sectionAdmin,
                tiles: [
                  _Tile(
                    icon: Icons.admin_panel_settings,
                    label: l.tileAdmin,
                    onTap: () => _push(context, const AdminHomePage()),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _push(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<void> _openCreateChannel(BuildContext context) async {
    final channel = await Navigator.push<ChatChannel>(
      context,
      MaterialPageRoute(builder: (_) => const CreateChannelPage()),
    );
    if (channel != null && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GroupChatPage(channel: channel)),
      );
    }
  }
}

class _Greeting extends StatelessWidget {
  final String? firstName;
  const _Greeting({required this.firstName});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final greeting =
        firstName == null ? l.greetingFallback : l.greetingNamed(firstName!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: text.headlineSmall?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l.greetingSubtitle,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final AsyncValue<List<CalendarEvent>> eventsAsync;
  final AsyncValue<List<MaintenanceRequest>> maintenanceAsync;
  final VoidCallback onTapNextEvent;
  final VoidCallback onTapMaintenance;

  const _StatusRow({
    required this.eventsAsync,
    required this.maintenanceAsync,
    required this.onTapNextEvent,
    required this.onTapMaintenance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NextEventCard(
            async: eventsAsync,
            onTap: onTapNextEvent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MaintenanceCard(
            async: maintenanceAsync,
            onTap: onTapMaintenance,
          ),
        ),
      ],
    );
  }
}

class _StatusCardShell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final VoidCallback onTap;

  const _StatusCardShell({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: text.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: text.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NextEventCard extends StatelessWidget {
  final AsyncValue<List<CalendarEvent>> async;
  final VoidCallback onTap;
  const _NextEventCard({required this.async, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final next = async.maybeWhen(
      data: (events) {
        final upcoming = events.where((e) => e.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        return upcoming.isEmpty ? null : upcoming.first;
      },
      orElse: () => null,
    );

    final l = AppLocalizations.of(context);
    final value = async.isLoading
        ? '…'
        : next?.title ?? l.statusNothingUpcoming;
    final subtitle = next == null
        ? null
        : DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag())
            .add_jm()
            .format(next.date);

    return _StatusCardShell(
      icon: Icons.event,
      label: l.statusNextEvent,
      value: value,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final AsyncValue<List<MaintenanceRequest>> async;
  final VoidCallback onTap;
  const _MaintenanceCard({required this.async, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Mirror the admin page's open/closed split — see
    // `maintenance_admin_page.dart` which only ever transitions between
    // 'open' and 'closed'. If a new status is ever introduced, update
    // both sites together.
    final openCount = async.maybeWhen(
      data: (list) => list.where((r) => r.status != 'closed').length,
      orElse: () => null,
    );

    final l = AppLocalizations.of(context);
    final value = async.isLoading
        ? '…'
        : openCount == null
            ? '—'
            : '$openCount';
    final subtitle = openCount == null
        ? null
        : openCount == 1 ? l.statusOpenTicket : l.statusOpenTicketsPlural;

    return _StatusCardShell(
      icon: Icons.build,
      label: l.statusMaintenance,
      value: value,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final List<_Tile> tiles;
  const _DashboardSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: text.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1,
          children: tiles,
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: scheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
