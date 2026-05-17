import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/clubs_providers.dart';
import '../services/club_service.dart';
import '../utils/user_helpers.dart';
import 'documents_page.dart';
import 'group_chat_page.dart';

class ClubDetailPage extends ConsumerStatefulWidget {
  final Club club;
  final ClubService? service;
  const ClubDetailPage({super.key, required this.club, this.service});

  @override
  ConsumerState<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends ConsumerState<ClubDetailPage> {
  late Club _club = widget.club;

  ClubService _resolveService() {
    final ClubService service = widget.service ?? ref.read(clubServiceProvider);
    return service;
  }

  Future<void> _joinAndChat() async {
    if (_club.id == null || _club.channelId == null) return;
    final updated = await _resolveService().joinClub(_club.id!);
    if (mounted) {
      setState(() => _club = updated);
      ref.invalidate(clubsProvider);
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(
          channel: ChatChannel(id: _club.channelId!, name: _club.name),
        ),
      ),
    );
  }

  void _openChat() {
    if (_club.channelId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(
          channel: ChatChannel(id: _club.channelId!, name: _club.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMember = _club.members.contains(currentUserId());
    return Scaffold(
      appBar: AppBar(title: Text(_club.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_club.description != null) Text(_club.description!),
            const SizedBox(height: 12),
            Text('Members: ${_club.members.length}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _club.channelId == null
                  ? null
                  : (isMember ? _openChat : _joinAndChat),
              child: Text(isMember ? 'Open Chat' : 'Join & Chat'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DocumentsPage()),
              ),
              child: const Text('Documents'),
            ),
          ],
        ),
      ),
    );
  }
}
