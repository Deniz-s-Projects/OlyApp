import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/qr_service.dart';

final qrServiceProvider = Provider<QrService>((ref) => QrService());
