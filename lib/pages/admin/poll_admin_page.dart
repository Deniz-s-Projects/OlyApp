import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/poll_service.dart';
import '../../utils/user_helpers.dart';

class PollAdminPage extends StatefulWidget {
  final PollService? service;
  const PollAdminPage({super.key, this.service});

  @override
  State<PollAdminPage> createState() => _PollAdminPageState();
}

class _PollAdminPageState extends State<PollAdminPage> {
  late final PollService _service;
  final TextEditingController _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [];

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
      _optionCtrls.add(TextEditingController());
      _optionCtrls.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final question = _questionCtrl.text.trim();
    final options = _optionCtrls
        .map((c) => c.text.trim())
        .where((o) => o.isNotEmpty)
        .toList();
    if (question.isEmpty || options.length < 2) return;
    try {
      await _service.createPoll(Poll(question: question, options: options));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Poll created')));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create poll')));
    }
  }

  void _addOption() {
    setState(() {
      _optionCtrls.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Poll')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _questionCtrl,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              const SizedBox(height: 16),
              const Text('Options'),
              const SizedBox(height: 8),
              for (var i = 0; i < _optionCtrls.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _optionCtrls[i],
                    decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  ),
                ),
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Poll'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
