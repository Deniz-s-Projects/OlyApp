import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/models.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';

/// A simple login page with email/password and placeholder Google/Apple login buttons.
class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final GoogleSignIn? googleSignIn;
  final Future<AuthorizationCredentialAppleID> Function()? appleSignIn;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    this.googleSignIn,
    this.appleSignIn,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const bool useMock = false; // Toggle between mock and real API
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  /// Authenticate against real API endpoint
  Future<Map<String, dynamic>> _authenticate(
    String email,
    String password,
  ) async {
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
        },
      };
    }

    final service = AuthService();
    return service.login(email, password);
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final response = await _authenticate(email, password);

      // Store user info
      final userMap = response['user'] as Map<String, dynamic>;
      final user = User(
        id: userMap['id'] is int ? userMap['id'] as int : null,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        avatarUrl: userMap['avatarUrl'] as String?,
        isAdmin: (userMap['isAdmin'] ?? false) as bool,
      );
      final userBox = Hive.box<User>('userBox');
      await userBox.put('currentUser', user);

      widget.onLoginSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<User?> _handleGoogleSignIn() async {
    final signIn = widget.googleSignIn ?? GoogleSignIn();
    final account = await signIn.signIn();
    if (account == null) return null;
    final auth = await account.authentication;

    final user = User(
      name: account.displayName ?? account.email,
      email: account.email,
      avatarUrl: account.photoUrl,
    );

    final authBox = Hive.box('authBox');
    await authBox.put('token', auth.idToken ?? auth.accessToken);

    return user;
  }

  Future<User?> _handleAppleSignIn() async {
    final getCredential =
        widget.appleSignIn ??
        () => SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
    final credential = await getCredential();

    final fullName =
        credential.givenName != null && credential.familyName != null
            ? '${credential.givenName} ${credential.familyName}'
            : 'Apple User';
    final email = credential.email ?? '${credential.userIdentifier}@apple.com';

    final user = User(name: fullName, email: email, avatarUrl: null);

    final authBox = Hive.box('authBox');
    await authBox.put('token', credential.identityToken);

    return user;
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
                      onPressed:
                          () => setState(
                            () => _passwordVisible = !_passwordVisible,
                          ),
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
                    child:
                        _isLoading
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
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                setState(() => _isLoading = true);
                                try {
                                  final user = await _handleGoogleSignIn();
                                  if (!context.mounted) return;
                                  if (user != null) {
                                    final userBox = Hive.box<User>('userBox');
                                    await userBox.put('currentUser', user);
                                    widget.onLoginSuccess();
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Google sign-in failed: $e'),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
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
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                setState(() => _isLoading = true);
                                try {
                                  final user = await _handleAppleSignIn();
                                  if (!context.mounted) return;
                                  if (user != null) {
                                    final userBox = Hive.box<User>('userBox');
                                    await userBox.put('currentUser', user);
                                    widget.onLoginSuccess();
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Apple sign-in failed: $e',
                                        ),
                                      ),
                                    );
                                  } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
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
              const SizedBox(height: 24),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.pushNamed(context, '/register'),
                child: const Text('Create an account'),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
