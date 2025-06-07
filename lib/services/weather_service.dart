import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon&current_weather=true'
      '&hourly=temperature_2m,weathercode&forecast_days=1',
    );
    final res = await _client.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final current = data['current_weather'] as Map<String, dynamic>;
      final hourly = data['hourly'] as Map<String, dynamic>;
      final times = (hourly['time'] as List).cast<String>();
      final temps = (hourly['temperature_2m'] as List).cast<num>();
      final codes = (hourly['weathercode'] as List).cast<int>();
      final forecast = <WeatherForecast>[];
      for (var i = 0; i < times.length && i < 12; i++) {
        forecast.add(
          WeatherForecast(
            time: DateTime.parse(times[i]),
            temperature: temps[i].toDouble(),
            code: codes[i],
          ),
        );
      }
      return WeatherData(
        current: WeatherCondition(
          temperature: (current['temperature'] as num).toDouble(),
          windspeed: (current['windspeed'] as num).toDouble(),
          code: current['weathercode'] as int,
        ),
        forecast: forecast,
      );
    }
    throw Exception('Request failed: ${res.statusCode}');
  }
}

class WeatherData {
  final WeatherCondition current;
  final List<WeatherForecast> forecast;
  WeatherData({required this.current, required this.forecast});
}

class WeatherCondition {
  final double temperature;
  final double windspeed;
  final int code;
  WeatherCondition({
    required this.temperature,
    required this.windspeed,
    required this.code,
  });
}

class WeatherForecast {
  final DateTime time;
  final double temperature;
  final int code;
  WeatherForecast({
    required this.time,
    required this.temperature,
    required this.code,
  });
}
