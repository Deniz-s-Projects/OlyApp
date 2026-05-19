import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/models.dart';
import 'pages/auth_home_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/register_page.dart';
import 'pages/reset_password_page.dart';
import 'providers/locale_provider.dart';
import 'providers/route_request_provider.dart';
import 'services/notification_service.dart';
import 'theme.dart';

void main() {
  // Top-level zone catches async errors that escape the framework
  // (e.g. unhandled Futures). Report them to Crashlytics when available
  // and never let init failures break startup.
  runZonedGuarded<Future<void>>(_bootstrap, (error, stack) {
    if (_crashlyticsReady) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    } else {
      debugPrint('Uncaught zone error: $error\n$stack');
    }
  });
}

bool _crashlyticsReady = false;

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebaseAndCrashlytics();

  // intl needs locale-specific symbol data before `DateFormat(locale)` can
  // format anything outside the default (en_US). `null` loads all available
  // bundled locales, which is fine for our small set.
  await initializeDateFormatting();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters (assuming you generate or write these)
  Hive.registerAdapter(MaintenanceRequestAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(CalendarEventAdapter());
  Hive.registerAdapter(ItemCategoryAdapter());
  Hive.registerAdapter(ItemAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(NotificationRecordAdapter());

  // Open boxes
  await Hive.openBox('maintenanceBox');
  await Hive.openBox('messagesBox');
  await Hive.openBox('calendarBox');
  await Hive.openBox('eventsBox');
  await Hive.openBox('itemsBox');
  await Hive.openBox('lostFoundBox');
  await Hive.openBox('userBox');
  await Hive.openBox('authBox');
  await Hive.openBox('directoryBox');
  await Hive.openBox('favoritesBox');
  await Hive.openBox('settingsBox');
  await Hive.openBox('pinsBox');
  await Hive.openBox<NotificationRecord>('notificationsBox');

  // Initialize tile caching store when not running tests
  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    await FMTCObjectBoxBackend().initialise();
    final store = FMTCStore('mapTiles');
    if (!await store.manage.ready) {
      await store.manage.create();
    }
  }

  runApp(const ProviderScope(child: OlyApp()));
}

/// Initialise Firebase, then wire Crashlytics into Flutter's two global
/// error sinks. Defensive: any failure here logs to the debug console and
/// returns — the app must still launch even if telemetry is unavailable.
Future<void> _initFirebaseAndCrashlytics() async {
  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    debugPrint('Firebase.initializeApp failed: $e\n$st');
    return;
  }
  try {
    final crashlytics = FirebaseCrashlytics.instance;
    // Disable collection in debug builds and under flutter test so that
    // test runs and dev iterations don't spam the dashboard. Real devices
    // in release mode still report.
    final shouldCollect = !kDebugMode &&
        !Platform.environment.containsKey('FLUTTER_TEST');
    await crashlytics.setCrashlyticsCollectionEnabled(shouldCollect);
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
    _crashlyticsReady = true;
  } catch (e, st) {
    debugPrint('Crashlytics init failed: $e\n$st');
  }
}

class OlyApp extends ConsumerStatefulWidget {
  const OlyApp({super.key});

  static OlyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<OlyAppState>();

  @override
  ConsumerState<OlyApp> createState() => OlyAppState();
}

class OlyAppState extends ConsumerState<OlyApp> {
  bool _loggedIn = false;
  bool _isAdmin = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _seenOnboarding = true;
  final List<Map<String, String?>> _notifications = [];
  StreamSubscription<ForegroundMessage>? _foregroundMessageSub;

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settingsBox');
    final stored =
        settingsBox.get('themeMode', defaultValue: 'system') as String;
    _seenOnboarding =
        settingsBox.get('seenOnboarding', defaultValue: false) as bool;
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.system,
    );
    final authBox = Hive.box('authBox');
    final token = authBox.get('token');
    final userBox = Hive.box<User>('userBox');
    final user = userBox.get('currentUser');
    if (token != null && user != null) {
      _loggedIn = true;
      _isAdmin = user.isAdmin;
    }
    final notifBox = Hive.box<NotificationRecord>('notificationsBox');
    for (final n in notifBox.values.cast<NotificationRecord>()) {
      _notifications.add({'title': n.title, 'body': n.body});
    }
    _foregroundMessageSub =
        NotificationService().foregroundMessages.listen((msg) {
      if (!mounted) return;
      setState(() {
        _notifications.add({'title': msg.title, 'body': msg.body});
      });
      Hive.box<NotificationRecord>('notificationsBox').add(
        NotificationRecord(title: msg.title, body: msg.body),
      );
      final route = msg.route;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.title ?? 'Notification'),
          // Tap-to-route: only show the action when the server included a
          // recognised data.route. Forwards through the same
          // routeRequestProvider channel as background/cold-start taps.
          action: route == null
              ? null
              : SnackBarAction(
                  label: AppLocalizations.of(context).commonOpen,
                  onPressed: () => ref
                      .read(routeRequestProvider.notifier)
                      .state = route,
                ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _foregroundMessageSub?.cancel();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final userBox = Hive.box<User>('userBox');
    final user = userBox.get('currentUser');
    setState(() {
      _loggedIn = true;
      _isAdmin = user?.isAdmin ?? false;
    });
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await NotificationService().registerToken(token);
    }
  }

  Future<void> _logout() async {
    await Hive.box('authBox').clear();
    await Hive.box<User>('userBox').clear();
    setState(() {
      _loggedIn = false;
      _isAdmin = false;
    });
  }

  Future<void> _finishOnboarding() async {
    final box = Hive.box('settingsBox');
    await box.put('seenOnboarding', true);
    setState(() => _seenOnboarding = true);
  }

  Future<void> logout() => _logout();

  void updateThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    Hive.box('settingsBox').put('themeMode', mode.name);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'OlyApp',
      theme: OlyTheme.light(),
      darkTheme: OlyTheme.dark(),
      themeMode: _themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/login': (_) => LoginPage(onLoginSuccess: _handleLogin),
        '/register': (_) => RegisterPage(onRegistered: _handleLogin),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/reset': (_) => const ResetPasswordPage(),
      },
      home: !_seenOnboarding
          ? OnboardingPage(onFinish: _finishOnboarding)
          : _loggedIn
          ? MainPage(isAdmin: _isAdmin, onLogout: _logout)
          : const AuthHomePage(),
    );
  }
}
