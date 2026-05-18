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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (hint != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              hint!,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
