import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/poll_service.dart';
import '../../utils/user_helpers.dart';

class PollListAdminPage extends StatefulWidget {
  final PollService? service;
  const PollListAdminPage({super.key, this.service});

  @override
  State<PollListAdminPage> createState() => _PollListAdminPageState();
}

class _PollListAdminPageState extends State<PollListAdminPage> {
  late final PollService _service;
  List<Poll> _polls = [];

  @override
  void initState() {
    super.initState();
    if (!currentUserIsAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin access required')));
      });
    } else {
      _service = widget.service ?? PollService();
      _load();
    }
  }

  Future<void> _load() async {
    final polls = await _service.fetchPolls();
    setState(() => _polls = polls);
  }

  Future<void> _delete(String id) async {
    await _service.deletePoll(id);
    setState(() => _polls.removeWhere((p) => p.id == id));
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Polls')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _polls.length,
          itemBuilder: (ctx, i) {
            final poll = _polls[i];
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
                    for (var j = 0; j < poll.options.length; j++)
                      Text(
                        '${poll.options[j]} (${poll.counts.length > j ? poll.counts[j] : 0})',
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: poll.id != null
                            ? () => _delete(poll.id!)
                            : null,
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
