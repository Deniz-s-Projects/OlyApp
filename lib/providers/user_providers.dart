import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());
