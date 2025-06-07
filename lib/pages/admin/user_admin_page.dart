import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/user_service.dart';
import '../../utils/user_helpers.dart';

class UserAdminPage extends StatefulWidget {
  final UserService? service;
  const UserAdminPage({super.key, this.service});

  @override
  State<UserAdminPage> createState() => _UserAdminPageState();
}

class _UserAdminPageState extends State<UserAdminPage> {
  late final UserService _service;
  final TextEditingController _searchCtrl = TextEditingController();
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    if (!currentUserIsAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Admin access required')));
      });
    } else {
      _service = widget.service ?? UserService();
      _load();
    }
  }

  Future<void> _load() async {
    final users = await _service.fetchUsers(search: _searchCtrl.text);
    if (mounted) setState(() => _users = users);
  }

  Future<void> _toggleAdmin(User user) async {
    final updated = User(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      isAdmin: !user.isAdmin,
      isListed: user.isListed,
      bio: user.bio,
      room: user.room,
    );
    await _service.updateUser(updated);
    _load();
  }

  Future<void> _delete(User user) async {
    if (user.id == null) return;
    await _service.deleteUser(user.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search users…',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _load,
                ),
              ),
              onChanged: (_) => _load(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (ctx, i) {
                  final u = _users[i];
                  return ListTile(
                    leading: u.avatarUrl != null
                        ? CircleAvatar(backgroundImage: NetworkImage(u.avatarUrl!))
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(u.name),
                    subtitle: Text(u.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: u.isAdmin,
                          onChanged: (_) => _toggleAdmin(u),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _delete(u),
                        ),
                      ],
                    ),
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
