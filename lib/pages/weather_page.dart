import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/weather_providers.dart';
import '../services/weather_service.dart';

class WeatherPage extends StatelessWidget {
  final WeatherService? service;
  const WeatherPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    if (service == null) return const _WeatherBody();
    return ProviderScope(
      overrides: [weatherServiceProvider.overrideWithValue(service!)],
      child: const _WeatherBody(),
    );
  }
}

class _WeatherBody extends ConsumerWidget {
  const _WeatherBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final weatherAsync = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: weatherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load')),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(weatherProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Current: ${data.current.temperature.toStringAsFixed(1)}°C, '
                'wind ${data.current.windspeed.toStringAsFixed(1)} km/h',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Next hours:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...data.forecast.map(
                (f) => ListTile(
                  leading: Text(
                    '${f.time.hour.toString().padLeft(2, '0')}:00',
                  ),
                  title: Text('${f.temperature.toStringAsFixed(1)}°C'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
