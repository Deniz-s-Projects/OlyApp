import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/reset_password_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'dart:io';
import 'models/models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters (assuming you generate or write these)
  Hive.registerAdapter(MaintenanceRequestAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(CalendarEventAdapter());
  Hive.registerAdapter(ItemCategoryAdapter());
  Hive.registerAdapter(ItemAdapter());
  Hive.registerAdapter(UserAdapter());

  // Open boxes
  await Hive.openBox('maintenanceBox');
  await Hive.openBox('messagesBox');
  await Hive.openBox('calendarBox');
  await Hive.openBox('eventsBox');
  await Hive.openBox('itemsBox');
  await Hive.openBox('userBox');
  await Hive.openBox('authBox');
  await Hive.openBox('favoritesBox');
  await Hive.openBox('settingsBox');
  await Hive.openBox('pinsBox');

  // Initialize tile caching store when not running tests
  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    await FMTCObjectBoxBackend().initialise();
    final store = FMTCStore('mapTiles');
    if (!await store.manage.ready) {
      await store.manage.create();
    }
  }

  runApp(const OlyApp());
}

class OlyApp extends StatefulWidget {
  const OlyApp({super.key});

  static OlyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<OlyAppState>();

  @override
  State<OlyApp> createState() => OlyAppState();
}

class OlyAppState extends State<OlyApp> {
  bool _loggedIn = false;
  bool _isAdmin = false;
  ThemeMode _themeMode = ThemeMode.light;
  final List<Map<String, String?>> _notifications = [];

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settingsBox');
    final stored =
        settingsBox.get('themeMode', defaultValue: 'light') as String;
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.light,
    );
    final authBox = Hive.box('authBox');
    final token = authBox.get('token');
    final userBox = Hive.box<User>('userBox');
    final user = userBox.get('currentUser');
    if (token != null && user != null) {
      _loggedIn = true;
      _isAdmin = user.isAdmin;
    }
    NotificationService().foregroundMessages.listen((data) {
      if (mounted) {
        setState(() {
          _notifications.add({'title': data['title'], 'body': data['body']});
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['title'] ?? 'Notification')),
        );
      }
    });
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

  void updateThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    Hive.box('settingsBox').put('themeMode', mode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OlyApp',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white38),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _themeMode,

      routes: {
        '/register': (_) => RegisterPage(onRegistered: _handleLogin),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/reset': (_) => const ResetPasswordPage(),
      },
      home:
          _loggedIn
              ? MainPage(
                isAdmin: _isAdmin,
                onLogout: _logout,
                notifications: _notifications,
              )
              : LoginPage(onLoginSuccess: () => _handleLogin()),
    );
  }
}
