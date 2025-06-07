import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingPage({super.key, required this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _current = 0;

  static const List<_OnboardData> _pages = [
    _OnboardData(
      icon: Icons.calendar_today,
      title: 'Stay Organized',
      description: 'Manage events and deadlines in the calendar.',
    ),
    _OnboardData(
      icon: Icons.swap_horiz,
      title: 'Exchange Items',
      description: 'Buy, sell or trade with your neighbors.',
    ),
    _OnboardData(
      icon: Icons.build,
      title: 'Request Maintenance',
      description: 'Report issues in your room and track tickets.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, index) {
                  final p = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 120, color: cs.primary),
                        const SizedBox(height: 32),
                        Text(
                          p.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final selected = i == _current;
                return Container(
                  margin: const EdgeInsets.all(4),
                  width: selected ? 12 : 8,
                  height: selected ? 12 : 8,
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onFinish,
                    child: const Text('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_current == _pages.length - 1) {
                        widget.onFinish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _current == _pages.length - 1 ? 'Done' : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
