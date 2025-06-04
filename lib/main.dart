import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'dart:io';
import 'models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await Hive.openBox('itemsBox');
  await Hive.openBox('userBox');
  await Hive.openBox('authBox');

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

  @override
  State<OlyApp> createState() => _OlyAppState();
}

class _OlyAppState extends State<OlyApp> {
  bool _loggedIn = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    final authBox = Hive.box('authBox');
    final token = authBox.get('token');
    final userBox = Hive.box<User>('userBox');
    final user = userBox.get('currentUser');
    if (token != null && user != null) {
      _loggedIn = true;
      _isAdmin = user.isAdmin;
    }
  }

  void _handleLogin() {
    final userBox = Hive.box<User>('userBox');
    final user = userBox.get('currentUser');
    setState(() {
      _loggedIn = true;
      _isAdmin = user?.isAdmin ?? false;
    });
  }

  Future<void> _logout() async {
    await Hive.box('authBox').clear();
    await Hive.box<User>('userBox').clear();
    setState(() {
      _loggedIn = false;
      _isAdmin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OlyApp',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white38),
        useMaterial3: true,
      ),
      home: _loggedIn
          ? MainPage(isAdmin: _isAdmin, onLogout: _logout)
          : LoginPage(onLoginSuccess: _handleLogin),
    );
  }
}
