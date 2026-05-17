import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/weather_service.dart';

final weatherServiceProvider =
    Provider<WeatherService>((ref) => WeatherService());

/// Current weather + forecast for the dorm coordinates. Refresh by
/// invalidating the provider.
final weatherProvider = FutureProvider<WeatherData>(
  (ref) async {
    final service = ref.watch(weatherServiceProvider);
    return service.fetchWeather(48.1740, 11.5475);
  },
  dependencies: [weatherServiceProvider],
);
