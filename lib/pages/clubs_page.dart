import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/club_service.dart';
import 'club_detail_page.dart';

class ClubsPage extends StatefulWidget {
  final ClubService? service;
  const ClubsPage({super.key, this.service});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  late final ClubService _service;
  List<Club> _clubs = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ClubService();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.fetchClubs();
    if (mounted) setState(() => _clubs = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _clubs.length,
        itemBuilder: (context, index) {
          final club = _clubs[index];
          return ListTile(
            title: Text(club.name),
            subtitle: Text(club.description ?? ''),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClubDetailPage(club: club, service: _service),
              ),
            ),
          );
        },
      ),
    );
  }
}
