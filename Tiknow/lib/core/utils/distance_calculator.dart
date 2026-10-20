import 'dart:math' as math;

/// Yürüme süresi hesabı: Haversine mesafe × 1,3 (sokak sapması) ÷ 80 m/dk,
/// yukarı yuvarlanır.
abstract final class DistanceCalculator {
  static const double earthRadiusMeters = 6371000;
  static const double detourFactor = 1.3;
  static const double walkingMetersPerMinute = 80;

  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _radians(lat2 - lat1);
    final dLon = _radians(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * earthRadiusMeters * math.asin(math.sqrt(a));
  }

  static int walkingMinutesForMeters(double straightMeters) {
    return (straightMeters * detourFactor / walkingMetersPerMinute).ceil();
  }

  static int walkingMinutes(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return walkingMinutesForMeters(haversineMeters(lat1, lon1, lat2, lon2));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
