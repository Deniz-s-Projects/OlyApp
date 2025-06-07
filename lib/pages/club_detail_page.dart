import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/club_service.dart';
import '../services/chat_service.dart';
import '../utils/user_helpers.dart';
import 'group_chat_page.dart';

class ClubDetailPage extends StatefulWidget {
  final Club club;
  final ClubService? service;
  const ClubDetailPage({super.key, required this.club, this.service});

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  late Club _club;
  late final ClubService _service;
  final ChatService _chat = ChatService();

  @override
  void initState() {
    super.initState();
    _club = widget.club;
    _service = widget.service ?? ClubService();
  }

  Future<void> _joinAndChat() async {
    if (_club.id == null || _club.channelId == null) return;
    final updated = await _service.joinClub(_club.id!);
    if (mounted) setState(() => _club = updated);
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
          ],
        ),
      ),
    );
  }
}
