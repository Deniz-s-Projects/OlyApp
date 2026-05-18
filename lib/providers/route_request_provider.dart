import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/nav_target.dart';

/// A request to navigate, typically triggered by a tapped push notification.
/// Consumed by [MainPage] which switches the current [NavTarget] in response.
class RouteRequest {
  final NavTarget target;
  final String? id;

  const RouteRequest(this.target, {this.id});

  /// Parse from an FCM message `data` map. FCM data values are always
  /// strings, so this is a string-keyed map by contract. Returns `null` if
  /// the route is missing or doesn't match a known [NavTarget].
  static RouteRequest? fromFcmData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final route = data['route'];
    if (route is! String) return null;
    final target = NavTarget.values.cast<NavTarget?>().firstWhere(
          (t) => t!.name == route,
          orElse: () => null,
        );
    if (target == null) return null;
    final id = data['id'];
    return RouteRequest(target, id: id is String ? id : null);
  }

  @override
  bool operator ==(Object other) =>
      other is RouteRequest && other.target == target && other.id == id;

  @override
  int get hashCode => Object.hash(target, id);
}

/// Holds the most recent navigation request from a push notification. The
/// listener (MainPage) consumes it by reading the value and then setting
/// this provider back to null so that re-mounts don't re-trigger the same
/// navigation.
final routeRequestProvider = StateProvider<RouteRequest?>((_) => null);
