import 'package:flutter/foundation.dart';

import '../../../core/utils/distance_calculator.dart';
import '../../active_rentals/models/active_rental_model.dart';
import '../../rental_packages/models/rental_package_model.dart';
import '../models/vehicle_catalog.dart';
import '../models/vehicle_model.dart';

/// Harita durumu: müsait araçlar, seçili araç ve seçili plan.
/// Kiralanmış araçlar haritadan düşer.
class RentalMapController {
  RentalMapController({
    required List<VehicleModel> vehicles,
    required this._activeRentals,
    this.userLatitude = VehicleCatalog.userLatitude,
    this.userLongitude = VehicleCatalog.userLongitude,
  })  : _allVehicles = vehicles,
        available = ValueNotifier<List<VehicleModel>>(vehicles) {
    _activeRentals.addListener(_refresh);
    _refresh();
  }

  final List<VehicleModel> _allVehicles;
  final ValueListenable<List<ActiveRentalModel>> _activeRentals;
  final double userLatitude;
  final double userLongitude;

  final ValueNotifier<List<VehicleModel>> available;
  final ValueNotifier<VehicleModel?> selected =
      ValueNotifier<VehicleModel?>(null);
  final ValueNotifier<RentalPlan> plan =
      ValueNotifier<RentalPlan>(const RentalPlan.perMinute());

  void select(VehicleModel? vehicle) {
    if (selected.value?.id != vehicle?.id) {
      plan.value = const RentalPlan.perMinute();
    }
    selected.value = vehicle;
  }

  void selectPlan(RentalPlan newPlan) => plan.value = newPlan;

  int walkingMinutesTo(VehicleModel vehicle) {
    return DistanceCalculator.walkingMinutes(
      userLatitude,
      userLongitude,
      vehicle.latitude,
      vehicle.longitude,
    );
  }

  void _refresh() {
    final rentedIds = {for (final r in _activeRentals.value) r.vehicle.id};
    available.value = [
      for (final v in _allVehicles)
        if (!rentedIds.contains(v.id)) v,
    ];
    final current = selected.value;
    if (current != null && rentedIds.contains(current.id)) selected.value = null;
  }

  void dispose() {
    _activeRentals.removeListener(_refresh);
    available.dispose();
    selected.dispose();
    plan.dispose();
  }
}
