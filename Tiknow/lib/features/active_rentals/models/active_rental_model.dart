import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../rental_map/models/vehicle_model.dart';
import '../../rental_packages/models/rental_package_model.dart';

enum RentalStatus { active, finished }

enum RentalExtraType { minutes, km }

/// Aktif ekranda sonradan eklenen süre/km. Ücreti bitişte toplama eklenir.
@immutable
class RentalExtraModel {
  const RentalExtraModel({
    required this.type,
    required this.amount,
    required this.fee,
    required this.addedAt,
  });

  final RentalExtraType type;
  final int amount; // dk veya km
  final double fee; // TL
  final DateTime addedAt;

  factory RentalExtraModel.fromJson(Map<String, dynamic> json) {
    return RentalExtraModel(
      type: RentalExtraType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RentalExtraType.minutes,
      ),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'amount': amount,
        'fee': fee,
        'addedAt': addedAt.toIso8601String(),
      };
}

/// Kiralama bitiş dökümü.
@immutable
class RentalSummary {
  const RentalSummary({
    required this.elapsedMinutes,
    required this.usedKm,
    required this.baseFee,
    required this.overageFee,
    required this.extrasFee,
  });

  final int elapsedMinutes;
  final int usedKm;
  final double baseFee;
  final double overageFee;
  final double extrasFee;

  double get total => baseFee + overageFee + extrasFee;
}

@immutable
class ActiveRentalModel {
  const ActiveRentalModel({
    required this.id,
    required this.vehicle,
    required this.plan,
    required this.startedAt,
    required this.includedMinutes,
    required this.includedKm,
    this.extras = const [],
    this.status = RentalStatus.active,
  });

  /// Kullanılan km şimdilik simüle edilir (gerçek GPS yok): şehir içi
  /// ortalama 30 km/sa.
  static const double simulatedKmPerMinute = 0.5;

  final String id;
  final VehicleModel vehicle;
  final RentalPlan plan;
  final DateTime startedAt;

  /// Paket hakkı + sonradan eklenenler. Dakikalık planda 0.
  final int includedMinutes;
  final int includedKm;
  final List<RentalExtraModel> extras;
  final RentalStatus status;

  bool get isPerMinute => plan.isPerMinute;
  RentalPackageModel? get package => plan.package;

  /// Yeni kiralama; hak ve fiyatlar plandan türetilir.
  factory ActiveRentalModel.start({
    required String id,
    required VehicleModel vehicle,
    required RentalPlan plan,
    required DateTime now,
  }) {
    final package = plan.package;
    return ActiveRentalModel(
      id: id,
      vehicle: vehicle,
      plan: plan,
      startedAt: now,
      includedMinutes: package?.minutes ?? 0,
      includedKm: package?.km ?? 0,
    );
  }

  // --- Saf fiyat / süre fonksiyonları (UI'sız, test edilebilir) ---

  int elapsedSeconds(DateTime now) =>
      math.max(0, now.difference(startedAt).inSeconds);

  /// Faturalanan dakika: başlanan dakika tam sayılır, en az 1.
  int elapsedMinutes(DateTime now) =>
      math.max(1, (elapsedSeconds(now) / 60).ceil());

  int usedKm(DateTime now) =>
      (elapsedSeconds(now) / 60 * simulatedKmPerMinute).floor();

  /// Kalan süre (saniye); hak bittiyse negatif.
  int remainingSeconds(DateTime now) =>
      includedMinutes * 60 - elapsedSeconds(now);

  int remainingKm(DateTime now) => includedKm - usedKm(now);

  int overMinutes(DateTime now) =>
      isPerMinute ? 0 : math.max(0, elapsedMinutes(now) - includedMinutes);

  int overKm(DateTime now) =>
      isPerMinute ? 0 : math.max(0, usedKm(now) - includedKm);

  double get baseFee => package?.price ?? 0;

  double get extrasFee => extras.fold(0.0, (sum, e) => sum + e.fee);

  double overageFee(DateTime now) {
    final p = package;
    if (p == null) return 0;
    return overMinutes(now) * p.extraPerMinute + overKm(now) * p.extraPerKm;
  }

  /// Dakikalıkta geçen süre × dakika fiyatı; pakette taban fiyat sıfırdır
  /// (paket ücreti `baseFee`, ödemede alınır).
  double perMinuteFee(DateTime now) =>
      isPerMinute ? elapsedMinutes(now) * vehicle.pricePerMinute : 0;

  /// Bitişte toplam: temel + aşım + ekler. Dakikalıkta temel ücret
  /// `geçenDakika × dakikaFiyatı`.
  RentalSummary summaryAt(DateTime now) {
    return RentalSummary(
      elapsedMinutes: elapsedMinutes(now),
      usedKm: usedKm(now),
      baseFee: isPerMinute ? perMinuteFee(now) : baseFee,
      overageFee: overageFee(now),
      extrasFee: extrasFee,
    );
  }

  ActiveRentalModel copyWith({
    String? id,
    VehicleModel? vehicle,
    RentalPlan? plan,
    DateTime? startedAt,
    int? includedMinutes,
    int? includedKm,
    List<RentalExtraModel>? extras,
    RentalStatus? status,
  }) {
    return ActiveRentalModel(
      id: id ?? this.id,
      vehicle: vehicle ?? this.vehicle,
      plan: plan ?? this.plan,
      startedAt: startedAt ?? this.startedAt,
      includedMinutes: includedMinutes ?? this.includedMinutes,
      includedKm: includedKm ?? this.includedKm,
      extras: extras ?? this.extras,
      status: status ?? this.status,
    );
  }

  factory ActiveRentalModel.fromJson(Map<String, dynamic> json) {
    final rawExtras = json['extras'] as List<dynamic>? ?? const [];
    return ActiveRentalModel(
      id: json['id'] as String? ?? '',
      vehicle: VehicleModel.fromJson(
        Map<String, dynamic>.from(json['vehicle'] as Map? ?? const {}),
      ),
      plan: RentalPlan.fromJson(
        Map<String, dynamic>.from(json['plan'] as Map? ?? const {}),
      ),
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      includedMinutes: (json['includedMinutes'] as num?)?.toInt() ?? 0,
      includedKm: (json['includedKm'] as num?)?.toInt() ?? 0,
      extras: [
        for (final e in rawExtras)
          RentalExtraModel.fromJson(Map<String, dynamic>.from(e as Map)),
      ],
      status: RentalStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => RentalStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicle.id,
        'vehicle': vehicle.toJson(),
        'plan': plan.toJson(),
        'startedAt': startedAt.toIso8601String(),
        'includedMinutes': includedMinutes,
        'includedKm': includedKm,
        'extras': [for (final e in extras) e.toJson()],
        'status': status.name,
      };
}
