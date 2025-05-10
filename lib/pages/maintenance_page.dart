import 'package:flutter/material.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  int _selectedTab = 0;
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Sample tickets; replace with real data source
  final List<Map<String, String>> _tickets = const [
    {'id': '1', 'subject': 'Leaky faucet', 'status': 'Open'},
    {'id': '2', 'subject': 'Broken window', 'status': 'In Progress'},
    {'id': '3', 'subject': 'AC not working', 'status': 'Closed'},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TabButton(
                  label: 'New Request',
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _TabButton(
                  label: 'Conversations',
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0 ? _buildForm(context) : _buildConversations(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: send to server
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request submitted!')),
              );
              _subjectController.clear();
              _descriptionController.clear();
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversations() {
    if (_tickets.isEmpty) {
      return const Center(child: Text('No conversations yet.'));
    }
    return ListView.separated(
      itemCount: _tickets.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        return ListTile(
          title: Text(ticket['subject']!),
          subtitle: Text('Status: ${ticket['status']}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: navigate to conversation thread
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Open ticket ${ticket['id']}')),
            );
          },
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}