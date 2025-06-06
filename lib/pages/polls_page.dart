import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/poll_service.dart';
import '../utils/user_helpers.dart';

class PollsPage extends StatefulWidget {
  final PollService? service;
  const PollsPage({super.key, this.service});

  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  late final PollService _service;
  List<Poll> _polls = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PollService();
    _load();
  }

  Future<void> _load() async {
    try {
      final polls = await _service.fetchPolls();
      if (!mounted) return;
      setState(() => _polls = polls);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load polls')),
      );
    }
  }

  Future<void> _vote(Poll poll, int index) async {
    if (poll.id == null) return;
    try {
      await _service.vote(poll.id!, index);
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit vote')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: _polls.length,
        itemBuilder: (context, index) {
          final poll = _polls[index];
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
                        onPressed: () => _vote(poll, i),
                        child: const Text('Vote'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
