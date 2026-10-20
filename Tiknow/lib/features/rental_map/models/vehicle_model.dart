import 'package:flutter/foundation.dart';

enum FuelType { petrol, diesel, hybrid, electric }

extension FuelTypeKeys on FuelType {
  /// `AppStrings` anahtarı (örn. `fuel_petrol`).
  String get labelKey => 'fuel_$name';

  /// Elektrikli araçta "Şarj", diğerlerinde "Yakıt".
  String get levelKey => this == FuelType.electric ? 'charge_level' : 'fuel_level';
}

@immutable
class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.model,
    required this.plate,
    required this.district,
    required this.isAutomatic,
    required this.fuelType,
    required this.fuelPercent,
    required this.pricePerMinute,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  final String id;
  final String model;
  final String plate;
  final String district;
  final bool isAutomatic;
  final FuelType fuelType;
  final int fuelPercent;
  final double pricePerMinute; // TL/dk
  final double latitude;
  final double longitude;
  final String imageUrl;

  VehicleModel copyWith({
    String? id,
    String? model,
    String? plate,
    String? district,
    bool? isAutomatic,
    FuelType? fuelType,
    int? fuelPercent,
    double? pricePerMinute,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      district: district ?? this.district,
      isAutomatic: isAutomatic ?? this.isAutomatic,
      fuelType: fuelType ?? this.fuelType,
      fuelPercent: fuelPercent ?? this.fuelPercent,
      pricePerMinute: pricePerMinute ?? this.pricePerMinute,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String? ?? '',
      model: json['model'] as String? ?? '',
      plate: json['plate'] as String? ?? '',
      district: json['district'] as String? ?? '',
      isAutomatic: json['isAutomatic'] as bool? ?? false,
      fuelType: FuelType.values.firstWhere(
        (f) => f.name == json['fuelType'],
        orElse: () => FuelType.petrol,
      ),
      fuelPercent: (json['fuelPercent'] as num?)?.toInt() ?? 0,
      pricePerMinute: (json['pricePerMinute'] as num?)?.toDouble() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'plate': plate,
        'district': district,
        'isAutomatic': isAutomatic,
        'fuelType': fuelType.name,
        'fuelPercent': fuelPercent,
        'pricePerMinute': pricePerMinute,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
      };
}
