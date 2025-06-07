import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/directory_service.dart';
import 'user_chat_page.dart';

class DirectoryPage extends StatefulWidget {
  final DirectoryService? service;
  const DirectoryPage({super.key, this.service});

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  late final DirectoryService _service;
  final TextEditingController _searchCtrl = TextEditingController();
  List<User> _users = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? DirectoryService();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await _service.fetchUsers(search: _searchCtrl.text);
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load users')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search residents…',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadUsers,
                ),
              ),
              onChanged: (_) => _loadUsers(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? const Center(child: Text('No residents found.'))
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return ListTile(
                              leading: user.avatarUrl != null
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.avatarUrl!),
                                    )
                                  : const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(user.name),
                              subtitle: Text(user.email),
                              onTap: () {
                                if (user.id == null) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserChatPage(user: user),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
