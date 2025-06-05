import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../main.dart';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  final UserService? service;
  const ProfilePage({super.key, this.service});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Box<User> _userBox;
  late User _user;
  bool _darkMode = false;
  late final UserService _service;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _avatarCtrl;
  XFile? _avatarFile;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? UserService();
    _userBox = Hive.box<User>('userBox');
    _user = _userBox.get('currentUser')!;
    _nameCtrl = TextEditingController(text: _user.name);
    _emailCtrl = TextEditingController(text: _user.email);
    _avatarCtrl = TextEditingController(text: _user.avatarUrl ?? '');
    _avatarCtrl.addListener(() => setState(() {}));
    final settingsBox = Hive.box('settingsBox');
    _darkMode = settingsBox.get('themeMode', defaultValue: 'light') == 'dark';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null) {
      setState(() => _avatarFile = file);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_avatarFile != null) {
      try {
        final path = await _service.uploadAvatar(File(_avatarFile!.path));
        _avatarCtrl.text = path;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
        return;
      }
    }
    final updated = User(
      id: _user.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      avatarUrl: _avatarCtrl.text.trim().isEmpty
          ? null
          : _avatarCtrl.text.trim(),
      isAdmin: _user.isAdmin,
    );
    try {
      final user = await _service.updateProfile(updated);
      await _userBox.put('currentUser', user);
      if (mounted) {
        setState(() => _user = user);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _avatarCtrl.text.trim();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _avatarCtrl,
                decoration: const InputDecoration(labelText: 'Avatar URL'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ],
              ),
              if (_avatarFile != null) ...[
                const SizedBox(height: 12),
                Image.file(File(_avatarFile!.path), height: 120),
              ],
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: _darkMode,
                onChanged: (val) {
                  setState(() => _darkMode = val);
                  final mode = val ? ThemeMode.dark : ThemeMode.light;
                  OlyApp.of(context)?.updateThemeMode(mode);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
