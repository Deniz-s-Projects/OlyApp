import 'package:flutter/material.dart';

/// Simple landing page with Login and Register buttons.
class AuthHomePage extends StatelessWidget {
  const AuthHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.secondary,
                    foregroundColor: cs.onSecondary,
                  ),
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
