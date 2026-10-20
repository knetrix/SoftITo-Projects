import 'package:flutter/foundation.dart';

@immutable
class RentalPackageModel {
  const RentalPackageModel({
    required this.id,
    required this.nameKey,
    required this.minutes,
    required this.km,
    required this.price,
    required this.extraPerKm,
    required this.extraPerMinute,
  });

  final String id;

  /// `AppStrings` anahtarı (örn. `package_hour1`).
  final String nameKey;
  final int minutes;
  final int km;
  final double price; // TL
  final double extraPerKm; // Aşım / ek km: TL/km
  final double extraPerMinute; // Aşım / ek süre: TL/dk

  static const List<RentalPackageModel> all = [
    RentalPackageModel(
      id: 'hour1',
      nameKey: 'package_hour1',
      minutes: 60,
      km: 30,
      price: 150,
      extraPerKm: 2.90,
      extraPerMinute: 2.90,
    ),
    RentalPackageModel(
      id: 'hour3',
      nameKey: 'package_hour3',
      minutes: 180,
      km: 80,
      price: 380,
      extraPerKm: 2.90,
      extraPerMinute: 2.90,
    ),
    RentalPackageModel(
      id: 'day',
      nameKey: 'package_day',
      minutes: 1440,
      km: 250,
      price: 900,
      extraPerKm: 2.60,
      extraPerMinute: 2.60,
    ),
  ];

  static RentalPackageModel? byId(String? id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// Kiralama planı: dakikalık veya bir paket.
@immutable
class RentalPlan {
  const RentalPlan.perMinute() : packageId = null;
  const RentalPlan.package(String this.packageId);

  final String? packageId;

  bool get isPerMinute => packageId == null;

  RentalPackageModel? get package => RentalPackageModel.byId(packageId);

  factory RentalPlan.fromJson(Map<String, dynamic> json) {
    final id = json['packageId'] as String?;
    if (id == null || RentalPackageModel.byId(id) == null) {
      return const RentalPlan.perMinute();
    }
    return RentalPlan.package(id);
  }

  Map<String, dynamic> toJson() => {'packageId': packageId};

  @override
  bool operator ==(Object other) =>
      other is RentalPlan && other.packageId == packageId;

  @override
  int get hashCode => packageId.hashCode;
}
