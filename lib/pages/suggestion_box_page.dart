import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/suggestions_providers.dart';
import '../services/suggestion_service.dart';
import '../utils/user_helpers.dart';

class SuggestionBoxPage extends StatelessWidget {
  final SuggestionService? service;
  const SuggestionBoxPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) {
      return const _SuggestionBoxBody();
    }
    return ProviderScope(
      overrides: [suggestionServiceProvider.overrideWithValue(service!)],
      child: const _SuggestionBoxBody(),
    );
  }
}

class _SuggestionBoxBody extends ConsumerStatefulWidget {
  const _SuggestionBoxBody();

  @override
  ConsumerState<_SuggestionBoxBody> createState() => _SuggestionBoxBodyState();
}

class _SuggestionBoxBodyState extends ConsumerState<_SuggestionBoxBody> {
  final TextEditingController _ctrl = TextEditingController();

  bool get _isAdmin => currentUserIsAdmin();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    try {
      await ref.read(suggestionServiceProvider).createSuggestion(
            Suggestion(userId: currentUserId(), content: text),
          );
      if (!mounted) return;
      _ctrl.clear();
      if (_isAdmin) ref.invalidate(suggestionsProvider);
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
    await ref.read(suggestionServiceProvider).deleteSuggestion(s.id!);
    if (!mounted) return;
    ref.invalidate(suggestionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final suggestions = _isAdmin
        ? (ref.watch(suggestionsProvider).valueOrNull ?? const <Suggestion>[])
        : const <Suggestion>[];
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
                onRefresh: () async => ref.invalidate(suggestionsProvider),
                child: suggestions.isEmpty
                    ? const Center(child: Text('No suggestions yet.'))
                    : ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (_, i) {
                          final s = suggestions[i];
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
