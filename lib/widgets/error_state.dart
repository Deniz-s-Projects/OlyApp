import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../theme/tokens.dart';

/// Generic inline error panel for failed async loads.
class ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? title;

  const ErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    // SingleChildScrollView so the panel survives tight constraints (e.g.
    // an Expanded beneath a TableCalendar) without RenderFlex overflow.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: scheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              title ?? l.errorGeneric,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(l.errorRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
