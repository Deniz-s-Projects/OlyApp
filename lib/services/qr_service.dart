import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';

import 'api_service.dart';

class QrService extends ApiService {
  QrService({super.client});

  Map<String, String> _headers([Map<String, String>? extra]) {
    final box = Hive.isBoxOpen('authBox') ? Hive.box('authBox') : null;
    final token = box?.get('token') as String?;
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      if (extra != null) ...extra,
    };
  }

  Future<Uint8List> fetchQrCode(int eventId) async {
    final response = await client.get(
      buildUri('/events/$eventId/qr'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }

  Future<void> checkIn(int eventId) async {
    final res = await client.post(
      buildUri('/events/$eventId/checkin'),
      headers: _headers({'Content-Type': 'application/json'}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Request failed: ${res.statusCode}');
    }
  }
}
