import 'package:flutter/material.dart';

void main() {
  runApp(const OlyApp());
}

class OlyApp extends StatelessWidget {
  const OlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OlyApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OlyApp')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.yellow),
            title: const Text('Calendar'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: Colors.yellow),
            title: const Text('Item Exchange'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ItemExchangePage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.build, color: Colors.yellow),
            title: const Text('Maintenance'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MaintenancePage()),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: const Center(child: Text('Calendar events will load here.')),
    );
  }
}

class ItemExchangePage extends StatelessWidget {
  const ItemExchangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Exchange')),
      body: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        children: const [
          ItemCard(title: 'Table'),
          SizedBox(width: 12),
          ItemCard(title: 'Textbook'),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final String title;
  const ItemCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.shade800),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
              onPressed: () {
                // Send to server later
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitted!')));
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
