import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/validators.dart';

/// A simple login page with email/password and placeholder Google/Apple login buttons.
class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const bool useMock = true; // Toggle between mock and real API
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  /// Authenticate against real API endpoint
  Future<Map<String, dynamic>> _authenticate(
      String email, String password) async {
    if (useMock) {
      // Mock response for local testing
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'token': 'mock_token_12345',
        'user': {
          'id': 1,
          'name': 'Mock User',
          'email': email,
          'avatarUrl': null,
          'isAdmin': email == 'admin@example.com',
        }
      };
    }

    // TODO: Replace with real api call
    final uri = Uri.parse('https://example.com/api/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final response = await _authenticate(email, password);

      // Store auth token
      final authBox = Hive.box('authBox');
      await authBox.put('token', response['token']);

      // Store user info
      final userMap = response['user'] as Map<String, dynamic>;
      final user = User.fromMap(userMap);
      final userBox = Hive.box<User>('userBox');
      await userBox.put('currentUser', user);

      widget.onLoginSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) => validateEmail(value);

  String? _validatePassword(String? value) => validatePassword(value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Or sign in with'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () async {
                        setState(() => _isLoading = true);
                        // TODO: Google Sign-In integration
                        await Future.delayed(
                            const Duration(seconds: 1));
                        widget.onLoginSuccess();
                        if (mounted) setState(() => _isLoading = false);
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () async {
                        setState(() => _isLoading = true);
                        // TODO: Apple Sign-In integration
                        await Future.delayed(
                            const Duration(seconds: 1));
                        widget.onLoginSuccess();
                        if (mounted) setState(() => _isLoading = false);
                      },
                      icon: const Icon(Icons.apple),
                      label: const Text('Apple'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: cs.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}