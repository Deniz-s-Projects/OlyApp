import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';

import '../models/models.dart';
import '../providers/auth_providers.dart';
import '../providers/storage_providers.dart';
import '../utils/validators.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final VoidCallback? onRegistered;
  const RegisterPage({super.key, this.onRegistered});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    if (_confirmPasswordCtrl.text != _passwordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.authPasswordsDoNotMatch)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ref.read(authServiceProvider).register(
            _nameCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
      final token = res['token'] as String;
      final userMap = res['user'] as Map<String, dynamic>;
      final user = User.fromMap(userMap);
      await ref.read(authStorageProvider).put('token', token);
      await ref.read(userStorageProvider).put('currentUser', user);
      widget.onRegistered?.call();
      if (widget.onRegistered == null && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.authRegistrationFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.authRegister)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: l.authName,
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l.authName : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: l.authEmail,
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: l.authPassword,
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      tooltip: _passwordVisible
                          ? l.a11yHidePassword
                          : l.a11yShowPassword,
                      onPressed: () => setState(
                        () => _passwordVisible = !_passwordVisible,
                      ),
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  decoration: InputDecoration(
                    labelText: l.authConfirmPassword,
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      validateConfirmPassword(v, _passwordCtrl.text),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.authRegister),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
