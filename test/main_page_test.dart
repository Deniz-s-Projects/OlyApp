import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oly_app/models/models.dart';
import 'package:oly_app/pages/calendar_page.dart';
import 'package:oly_app/pages/main_page.dart';
import 'package:oly_app/providers/calendar_providers.dart';
import 'package:oly_app/services/event_service.dart';

class FakeEventService extends EventService {
  final List<CalendarEvent> events = [];
  FakeEventService();
  @override
  Future<List<CalendarEvent>> fetchEvents() async => events;
  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    events.add(event);
    return event;
  }
}

// The dashboard + grouped tile grid is taller than the default 600x800 test
// surface. Bump to a phone-sized viewport so nothing overflows.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

// Builds a MaterialApp wired with the generated AppLocalizations delegates
// so pages can call `AppLocalizations.of(context)` without crashing. Locale
// pinned to English so existing string-match assertions stay valid.
MaterialApp _app({required Widget home}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  testWidgets('Bottom nav exposes the five primary destinations',
      (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: _app(home: const MainPage(onLogout: null)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);

    // The NavigationBar should expose exactly five destinations.
    final destinations = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byType(NavigationDestination),
    );
    expect(destinations, findsNWidgets(5));
  });

  testWidgets('Tapping Calendar destination switches to calendar surface',
      (tester) async {
    _useTallSurface(tester);
    final fakeEventService = FakeEventService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventServiceProvider.overrideWithValue(fakeEventService),
        ],
        child: _app(
          home: MainPage(
            calendarPage: CalendarPage(service: fakeEventService),
            onLogout: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.calendar_today_outlined),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Calendar'), findsOneWidget);
    // Regular users see no FAB on the calendar tab.
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Admin tile visible on dashboard for admins', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: _app(home: const MainPage(isAdmin: true, onLogout: null)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('Admin tile hidden on dashboard for regular users',
      (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: _app(home: const MainPage(onLogout: null)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('Calendar FAB visible for admins on calendar tab',
      (tester) async {
    _useTallSurface(tester);
    final fakeEventService = FakeEventService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventServiceProvider.overrideWithValue(fakeEventService),
        ],
        child: _app(
          home: MainPage(
            calendarPage: CalendarPage(service: fakeEventService),
            isAdmin: true,
            onLogout: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.calendar_today_outlined),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.widgetWithIcon(FloatingActionButton, Icons.event),
      findsOneWidget,
    );
  });
}
