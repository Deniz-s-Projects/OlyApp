import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';
import 'error_state.dart';
import 'loading_state.dart';

/// Renders an [AsyncValue] uniformly across the app: loading, error, empty,
/// data. Pages should prefer this to ad-hoc `value.isLoading ? ... : ...`.
///
/// - [value] is the AsyncValue being rendered.
/// - [data] builds the success state given the resolved value.
/// - [isEmpty] returns `true` when the resolved data should render as empty.
///   When omitted, no empty branch is shown.
/// - [empty] is the widget shown when [isEmpty] returns true. Required if
///   [isEmpty] is provided.
/// - [loading] / [error] / [errorTitle] / [onRetry] / [loadingHint] customize
///   the non-data branches.
class AsyncStateView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final Widget? loading;
  final Widget Function(Object error, StackTrace stack)? error;
  final String? errorTitle;
  final VoidCallback? onRetry;
  final String? loadingHint;

  const AsyncStateView({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.empty,
    this.loading,
    this.error,
    this.errorTitle,
    this.onRetry,
    this.loadingHint,
  }) : assert(
          isEmpty == null || empty != null,
          'When isEmpty is provided, empty must also be provided.',
        );

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? LoadingState(hint: loadingHint),
      error: (err, stack) =>
          error?.call(err, stack) ??
          ErrorState(error: err, onRetry: onRetry, title: errorTitle),
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return empty ?? const EmptyState(icon: Icons.inbox, title: 'Empty');
        }
        return data(d);
      },
    );
  }
}
