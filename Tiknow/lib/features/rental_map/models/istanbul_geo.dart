import 'dart:ui';

/// (boylam, enlem) çifti.
typedef GeoPoint = ({double lon, double lat});

/// Haritanın gösterdiği İstanbul penceresi ve enlem/boylam -> 0..1 dönüşümü.
abstract final class IstanbulGeo {
  static const double lonMin = 28.90;
  static const double lonMax = 29.12;
  static const double latMin = 40.95;
  static const double latMax = 41.10;

  /// Harita tuvalinin en/boy oranı (yaklaşık gerçek km oranı).
  static const double aspectRatio = 1.11;

  /// 0..1 normalize konum (sol-üst orijin).
  static Offset normalize(double lat, double lon) {
    return Offset(
      (lon - lonMin) / (lonMax - lonMin),
      (latMax - lat) / (latMax - latMin),
    );
  }

  static Offset normalizePoint(GeoPoint p) => normalize(p.lat, p.lon);

  /// Avrupa yakası kara parçası (Boğaz, Haliç ve Marmara kıyısı dahil).
  static const List<GeoPoint> europeLand = [
    (lon: 28.90, lat: 41.10),
    (lon: 29.057, lat: 41.10),
    (lon: 29.056, lat: 41.085),
    (lon: 29.043, lat: 41.077),
    (lon: 29.037, lat: 41.064),
    (lon: 29.025, lat: 41.048),
    (lon: 29.005, lat: 41.042),
    (lon: 28.992, lat: 41.032),
    (lon: 28.974, lat: 41.022),
    // Haliç kuzey kıyısı (ağza doğru -> kuzeybatı)
    (lon: 28.968, lat: 41.030),
    (lon: 28.958, lat: 41.040),
    (lon: 28.948, lat: 41.050),
    (lon: 28.938, lat: 41.060),
    (lon: 28.930, lat: 41.062),
    // Haliç güney kıyısı (geri dönüş)
    (lon: 28.934, lat: 41.056),
    (lon: 28.944, lat: 41.047),
    (lon: 28.954, lat: 41.037),
    (lon: 28.964, lat: 41.026),
    (lon: 28.976, lat: 41.017),
    (lon: 28.985, lat: 41.0145), // Sarayburnu
    // Marmara kıyısı
    (lon: 28.9835, lat: 41.008),
    (lon: 28.975, lat: 41.0025),
    (lon: 28.962, lat: 40.999),
    (lon: 28.945, lat: 40.9975),
    (lon: 28.92, lat: 40.994),
    (lon: 28.90, lat: 40.990),
  ];

  /// Anadolu yakası kara parçası.
  static const List<GeoPoint> asiaLand = [
    (lon: 29.12, lat: 41.10),
    (lon: 29.068, lat: 41.10),
    (lon: 29.066, lat: 41.085),
    (lon: 29.063, lat: 41.07),
    (lon: 29.055, lat: 41.055),
    (lon: 29.04, lat: 41.045),
    (lon: 29.025, lat: 41.032),
    (lon: 29.012, lat: 41.022),
    (lon: 29.014, lat: 41.005),
    (lon: 29.02, lat: 40.995),
    (lon: 29.03, lat: 40.985),
    (lon: 29.025, lat: 40.975),
    (lon: 29.037, lat: 40.966),
    (lon: 29.06, lat: 40.962),
    (lon: 29.09, lat: 40.95),
    (lon: 29.12, lat: 40.95),
  ];

  /// Park / yeşil alan merkezleri ve yarıçapları (enlem/boylam derecesi).
  static const List<({GeoPoint center, double radiusLon, double radiusLat})>
      parks = [
    (center: (lon: 29.012, lat: 41.050), radiusLon: 0.006, radiusLat: 0.0045),
    (center: (lon: 28.981, lat: 41.0135), radiusLon: 0.004, radiusLat: 0.003),
    (center: (lon: 29.032, lat: 41.016), radiusLon: 0.007, radiusLat: 0.005),
    (center: (lon: 29.075, lat: 41.027), radiusLon: 0.008, radiusLat: 0.006),
    (center: (lon: 29.040, lat: 40.972), radiusLon: 0.006, radiusLat: 0.004),
  ];

  /// Ana yollar (köprüler ve sahil yolları).
  static const List<List<GeoPoint>> majorRoads = [
    // 15 Temmuz Şehitler Köprüsü / O-1
    [
      (lon: 28.90, lat: 41.065),
      (lon: 28.95, lat: 41.070),
      (lon: 28.99, lat: 41.068),
      (lon: 29.015, lat: 41.052),
      (lon: 29.035, lat: 41.045),
      (lon: 29.06, lat: 41.040),
      (lon: 29.10, lat: 41.040),
      (lon: 29.12, lat: 41.040),
    ],
    // FSM Köprüsü / O-2
    [
      (lon: 28.90, lat: 41.095),
      (lon: 28.98, lat: 41.098),
      (lon: 29.062, lat: 41.092),
      (lon: 29.12, lat: 41.088),
    ],
    // Kennedy Caddesi (Avrupa sahil yolu)
    [
      (lon: 28.90, lat: 40.995),
      (lon: 28.935, lat: 41.001),
      (lon: 28.962, lat: 41.004),
      (lon: 28.978, lat: 41.011),
    ],
    // Beşiktaş - Bebek sahil yolu
    [
      (lon: 28.990, lat: 41.036),
      (lon: 29.003, lat: 41.044),
      (lon: 29.022, lat: 41.052),
      (lon: 29.035, lat: 41.068),
      (lon: 29.046, lat: 41.082),
    ],
    // Anadolu yakası D-100
    [
      (lon: 29.028, lat: 40.996),
      (lon: 29.060, lat: 40.980),
      (lon: 29.090, lat: 40.966),
      (lon: 29.12, lat: 40.958),
    ],
    // Anadolu yakası E-5
    [
      (lon: 29.035, lat: 41.042),
      (lon: 29.045, lat: 41.015),
      (lon: 29.070, lat: 41.000),
      (lon: 29.12, lat: 40.990),
    ],
  ];

  /// Ara sokak / cadde ağı.
  static const List<List<GeoPoint>> minorRoads = [
    [(lon: 28.90, lat: 41.012), (lon: 28.925, lat: 41.020), (lon: 28.943, lat: 41.033)],
    [(lon: 28.985, lat: 41.032), (lon: 28.985, lat: 41.060), (lon: 28.990, lat: 41.095)],
    [(lon: 28.995, lat: 41.040), (lon: 29.000, lat: 41.070), (lon: 29.010, lat: 41.098)],
    [(lon: 28.945, lat: 41.012), (lon: 28.975, lat: 41.032), (lon: 28.992, lat: 41.034)],
    [(lon: 28.930, lat: 41.070), (lon: 28.970, lat: 41.062), (lon: 28.985, lat: 41.045)],
    [(lon: 29.022, lat: 40.992), (lon: 29.040, lat: 41.012), (lon: 29.050, lat: 41.040)],
    [(lon: 29.030, lat: 40.990), (lon: 29.070, lat: 40.995), (lon: 29.100, lat: 41.020)],
    [(lon: 29.070, lat: 41.098), (lon: 29.085, lat: 41.060), (lon: 29.100, lat: 41.020)],
    [(lon: 29.040, lat: 41.070), (lon: 29.030, lat: 41.085), (lon: 29.025, lat: 41.098)],
    [(lon: 28.910, lat: 41.030), (lon: 28.915, lat: 41.060), (lon: 28.920, lat: 41.095)],
  ];
}
