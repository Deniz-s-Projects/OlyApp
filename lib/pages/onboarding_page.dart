import 'package:flutter/material.dart';
import 'package:oly_app/l10n/generated/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingPage({super.key, required this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _current = 0;

  // Icons stay as constants; titles/bodies are resolved per build so they
  // pick up the active locale. Indexes 1–3 map to the onboardingTitleN /
  // onboardingBodyN keys.
  static const List<IconData> _icons = [
    Icons.calendar_today,
    Icons.swap_horiz,
    Icons.build,
  ];

  List<_OnboardData> pagesFor(AppLocalizations l) => [
        _OnboardData(_icons[0], l.onboardingTitle1, l.onboardingBody1),
        _OnboardData(_icons[1], l.onboardingTitle2, l.onboardingBody2),
        _OnboardData(_icons[2], l.onboardingTitle3, l.onboardingBody3),
      ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final pages = pagesFor(l);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, index) {
                  final p = pages[index];
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
              children: List.generate(pages.length, (i) {
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
                    child: Text(l.onboardingSkip),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_current == pages.length - 1) {
                        widget.onFinish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _current == pages.length - 1
                          ? l.onboardingDone
                          : l.onboardingNext,
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
  const _OnboardData(this.icon, this.title, this.description);
}
