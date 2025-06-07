import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  final WeatherService? service;
  const WeatherPage({super.key, this.service});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late final WeatherService _service;
  WeatherData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WeatherService();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.fetchWeather(48.1740, 11.5475);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
          ? const Center(child: Text('Failed to load'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Current: ${_data!.current.temperature.toStringAsFixed(1)}°C, '
                    'wind ${_data!.current.windspeed.toStringAsFixed(1)} km/h',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Next hours:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._data!.forecast.map(
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
    );
  }
}
