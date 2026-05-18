import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Centered loading indicator with optional hint text. A seam for future
/// skeleton-shimmer implementations — pages should not call
/// CircularProgressIndicator directly.
class LoadingState extends StatelessWidget {
  final String? hint;

  const LoadingState({super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // SingleChildScrollView so the indicator + hint never overflow a tight
    // Expanded (e.g. beneath a TableCalendar in test viewports).
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
