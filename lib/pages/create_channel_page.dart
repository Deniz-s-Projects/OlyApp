import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/chat_service.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final ChatService _service = ChatService();
  bool _creating = false;

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _creating = true);
    try {
      final channel = await _service.createChannel(name);
      if (!mounted) return;
      Navigator.pop(context, channel);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Channel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Channel name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _creating ? null : _create,
              child: const Text('Create'),
            )
          ],
        ),
      ),
    );
  }
}
