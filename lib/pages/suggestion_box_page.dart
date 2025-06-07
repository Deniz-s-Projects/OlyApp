import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/suggestion_service.dart';
import '../utils/user_helpers.dart';

class SuggestionBoxPage extends StatefulWidget {
  final SuggestionService? service;
  const SuggestionBoxPage({super.key, this.service});

  @override
  State<SuggestionBoxPage> createState() => _SuggestionBoxPageState();
}

class _SuggestionBoxPageState extends State<SuggestionBoxPage> {
  late final SuggestionService _service;
  final TextEditingController _ctrl = TextEditingController();
  List<Suggestion> _suggestions = [];

  bool get _isAdmin => currentUserIsAdmin();

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SuggestionService();
    if (_isAdmin) _load();
  }

  Future<void> _load() async {
    final list = await _service.fetchSuggestions();
    if (!mounted) return;
    setState(() => _suggestions = list);
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    try {
      await _service.createSuggestion(
        Suggestion(userId: currentUserId(), content: text),
      );
      if (!mounted) return;
      _ctrl.clear();
      if (_isAdmin) _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for the feedback!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit')));
    }
  }

  Future<void> _delete(Suggestion s) async {
    if (s.id == null) return;
    await _service.deleteSuggestion(s.id!);
    if (!mounted) return;
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestion Box'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Enter your suggestion...',
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _submit),
              ],
            ),
          ),
          if (_isAdmin)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child:
                    _suggestions.isEmpty
                        ? const Center(child: Text('No suggestions yet.'))
                        : ListView.builder(
                          itemCount: _suggestions.length,
                          itemBuilder: (_, i) {
                            final s = _suggestions[i];
                            return ListTile(
                              title: Text(s.content),
                              subtitle: Text(
                                'User ${s.userId} - ${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _delete(s),
                              ),
                            );
                          },
                        ),
              ),
            ),
        ],
      ),
    );
  }
}
