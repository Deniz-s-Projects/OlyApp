import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class TransitService {
  TransitService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://transport.opendata.ch/v1';

  Uri _uri(String path, [Map<String, String>? params]) {
    return Uri.parse('$_baseUrl$path').replace(queryParameters: params);
  }

  Future<List<TransitStop>> searchStops(String query) async {
    final res = await _client.get(_uri('/locations', {'query': query}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['stations'] as List<dynamic>;
      return list
          .map((e) => TransitStop.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Request failed: ${res.statusCode}');
  }

  Future<List<TransitDeparture>> fetchDepartures(String stopId, {int limit = 10}) async {
    final res =
        await _client.get(_uri('/stationboard', {'id': stopId, 'limit': '$limit'}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['stationboard'] as List<dynamic>;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        final stop = map['stop'] as Map<String, dynamic>;
        return TransitDeparture(
          line: map['name'] as String,
          destination: map['to'] as String,
          time: DateTime.parse(stop['departure'] as String),
        );
      }).toList();
    }
    throw Exception('Request failed: ${res.statusCode}');
  }

  Future<List<TransitStop>> loadPinnedStops() async {
    final box = await Hive.openBox('transitBox');
    final list = box.get('pinned', defaultValue: const <dynamic>[]) as List;
    return list
        .map((e) => TransitStop.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> pinStop(TransitStop stop) async {
    final box = await Hive.openBox('transitBox');
    final list = box.get('pinned', defaultValue: const <dynamic>[]) as List;
    if (!list.any((e) => Map<String, dynamic>.from(e)['id'].toString() == stop.id)) {
      list.add(stop.toMap());
      await box.put('pinned', list);
    }
  }

  Future<void> unpinStop(String id) async {
    final box = await Hive.openBox('transitBox');
    final list = box.get('pinned', defaultValue: const <dynamic>[]) as List;
    list.removeWhere((e) => Map<String, dynamic>.from(e)['id'].toString() == id);
    await box.put('pinned', list);
  }
}
