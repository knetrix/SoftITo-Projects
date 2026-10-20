import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/storage_service.dart';
import '../../rental_map/models/vehicle_model.dart';
import '../../rental_packages/models/rental_package_model.dart';
import '../models/active_rental_model.dart';

/// Aktif kiralamalar. Saniyelik `now` yalnızca sayaç widget'larını yeniler;
/// zamanlayıcı yalnızca aktif kiralama varken çalışır.
class ActiveRentalsController {
  ActiveRentalsController(this._storage, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        rentals = ValueNotifier<List<ActiveRentalModel>>(
          _storage.loadRentals(),
        ) {
    now = ValueNotifier<DateTime>(_clock());
    rentals.addListener(_syncTimer);
    _syncTimer();
  }

  /// Süre uzatma seçenekleri (dk) ve ek km seçenekleri.
  static const List<int> extendMinuteOptions = [15, 30, 60];
  static const List<int> addKmOptions = [10, 25, 50];

  final StorageService _storage;
  final DateTime Function() _clock;
  final ValueNotifier<List<ActiveRentalModel>> rentals;
  late final ValueNotifier<DateTime> now;
  Timer? _timer;

  bool isRented(String vehicleId) =>
      rentals.value.any((r) => r.vehicle.id == vehicleId);

  ActiveRentalModel start(VehicleModel vehicle, RentalPlan plan) {
    final rental = ActiveRentalModel.start(
      id: 'r_${_clock().microsecondsSinceEpoch}',
      vehicle: vehicle,
      plan: plan,
      now: _clock(),
    );
    _update([...rentals.value, rental]);
    return rental;
  }

  /// Süre uzatma: hak artar, ücret bitişte ekstra olarak toplanır.
  /// Yalnızca paketlerde geçerlidir; ücreti döner.
  double extendTime(String rentalId, int minutes) {
    return _addExtra(rentalId, RentalExtraType.minutes, minutes);
  }

  double addKm(String rentalId, int km) {
    return _addExtra(rentalId, RentalExtraType.km, km);
  }

  /// Kiralamayı bitirir, listeden çıkarır ve dökümü döner.
  RentalSummary? finish(String rentalId) {
    final index = rentals.value.indexWhere((r) => r.id == rentalId);
    if (index < 0) return null;
    final summary = rentals.value[index].summaryAt(_clock());
    _update([
      for (final r in rentals.value)
        if (r.id != rentalId) r,
    ]);
    return summary;
  }

  double _addExtra(String rentalId, RentalExtraType type, int amount) {
    final index = rentals.value.indexWhere((r) => r.id == rentalId);
    if (index < 0 || amount <= 0) return 0;
    final rental = rentals.value[index];
    final package = rental.package;
    if (package == null) return 0;

    final isMinutes = type == RentalExtraType.minutes;
    final fee = amount * (isMinutes ? package.extraPerMinute : package.extraPerKm);
    final updated = rental.copyWith(
      includedMinutes: rental.includedMinutes + (isMinutes ? amount : 0),
      includedKm: rental.includedKm + (isMinutes ? 0 : amount),
      extras: [
        ...rental.extras,
        RentalExtraModel(
          type: type,
          amount: amount,
          fee: fee,
          addedAt: _clock(),
        ),
      ],
    );
    _update([
      for (final r in rentals.value) r.id == rentalId ? updated : r,
    ]);
    return fee;
  }

  void _update(List<ActiveRentalModel> next) {
    rentals.value = next;
    unawaited(_storage.saveRentals(next));
  }

  void _syncTimer() {
    if (rentals.value.isEmpty) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    now.value = _clock();
    _timer ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => now.value = _clock(),
    );
  }

  void dispose() {
    _timer?.cancel();
    rentals.removeListener(_syncTimer);
    rentals.dispose();
    now.dispose();
  }
}
