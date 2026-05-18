import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:oly_app/widgets/async_state_view.dart';

Future<void> _wrap(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AsyncStateView', () {
    testWidgets('renders LoadingState when value is loading', (tester) async {
      await _wrap(
        tester,
        AsyncStateView<List<int>>(
          value: const AsyncValue.loading(),
          data: (_) => const Text('DATA'),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('DATA'), findsNothing);
    });

    testWidgets('renders ErrorState with title and error message', (tester) async {
      await _wrap(
        tester,
        AsyncStateView<List<int>>(
          value: AsyncValue.error(
            Exception('boom'),
            StackTrace.empty,
          ),
          errorTitle: 'Could not load things',
          data: (_) => const Text('DATA'),
        ),
      );
      await tester.pump();
      expect(find.text('Could not load things'), findsOneWidget);
      expect(find.textContaining('boom'), findsOneWidget);
    });

    testWidgets('renders retry button only when onRetry is provided',
        (tester) async {
      var retried = 0;
      await _wrap(
        tester,
        AsyncStateView<List<int>>(
          value: AsyncValue.error(Exception('boom'), StackTrace.empty),
          onRetry: () => retried++,
          data: (_) => const Text('DATA'),
        ),
      );
      await tester.pump();
      final retry = find.widgetWithText(FilledButton, 'Retry');
      expect(retry, findsOneWidget);
      await tester.tap(retry);
      expect(retried, 1);
    });

    testWidgets('renders empty state when isEmpty returns true', (tester) async {
      await _wrap(
        tester,
        AsyncStateView<List<int>>(
          value: const AsyncValue.data(<int>[]),
          isEmpty: (data) => data.isEmpty,
          empty: const Center(child: Text('NOTHING HERE')),
          data: (_) => const Text('DATA'),
        ),
      );
      await tester.pump();
      expect(find.text('NOTHING HERE'), findsOneWidget);
      expect(find.text('DATA'), findsNothing);
    });

    testWidgets('renders data builder when not loading/error/empty',
        (tester) async {
      await _wrap(
        tester,
        AsyncStateView<List<int>>(
          value: const AsyncValue.data([1, 2, 3]),
          isEmpty: (data) => data.isEmpty,
          empty: const Text('NOTHING HERE'),
          data: (data) => Text('count=${data.length}'),
        ),
      );
      await tester.pump();
      expect(find.text('count=3'), findsOneWidget);
      expect(find.text('NOTHING HERE'), findsNothing);
    });
  });
}
