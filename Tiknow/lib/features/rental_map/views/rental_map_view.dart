import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/app_dependencies.dart';
import '../../active_rentals/models/active_rental_model.dart';
import '../../active_rentals/views/active_rentals_view.dart';
import '../../payment/views/payment_view.dart';
import '../../rental_packages/models/rental_package_model.dart';
import '../../settings/views/settings_view.dart';
import '../controllers/rental_map_controller.dart';
import '../models/vehicle_catalog.dart';
import '../models/vehicle_model.dart';
import '../widgets/rental_map_canvas_widget.dart';
import '../widgets/vehicle_panel_widget.dart';

/// Ana ekran: İstanbul haritası, araç simgeleri, ayarlar ve aktif kiralamalar.
class RentalMapView extends StatefulWidget {
  const RentalMapView({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<RentalMapView> createState() => _RentalMapViewState();
}

class _RentalMapViewState extends State<RentalMapView> {
  late final RentalMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RentalMapController(
      vehicles: VehicleCatalog.vehicles,
      activeRentals: widget.deps.activeRentals.rentals,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRental(VehicleModel vehicle, RentalPlan plan) async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentView(vehicle: vehicle, plan: plan),
      ),
    );
    if (paid != true || !mounted) return;
    widget.deps.activeRentals.start(vehicle, plan);
    _controller.select(null);
    _openActiveRentals();
  }

  void _openActiveRentals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveRentalsView(controller: widget.deps.activeRentals),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsView(deps: widget.deps)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RentalMapCanvasWidget(
              controller: _controller,
              onVehicleTap: _controller.select,
            ),
          ),
          _MapTopBar(onSettings: _openSettings),
          _BottomLayer(
            controller: _controller,
            activeRentals: widget.deps.activeRentals.rentals,
            onRent: _startRental,
            onOpenActive: _openActiveRentals,
          ),
        ],
      ),
    );
  }
}

class _MapTopBar extends StatelessWidget {
  const _MapTopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Positioned(
      left: 16,
      right: 16,
      top: MediaQuery.paddingOf(context).top + 8,
      child: Row(
        children: [
          Material(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(24),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                context.tr('app_name'),
                style: context.textStyles.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const Spacer(),
          Semantics(
            button: true,
            label: context.tr('settings'),
            child: IconButton.filled(
              tooltip: context.tr('settings'),
              style: IconButton.styleFrom(
                backgroundColor: scheme.surface,
                foregroundColor: scheme.onSurface,
                minimumSize: const Size(48, 48),
                elevation: 3,
                shadowColor: scheme.shadow,
              ),
              onPressed: onSettings,
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seçili araç varsa panel, yoksa "Aktif Kiralamalar" butonu.
class _BottomLayer extends StatelessWidget {
  const _BottomLayer({
    required this.controller,
    required this.activeRentals,
    required this.onRent,
    required this.onOpenActive,
  });

  final RentalMapController controller;
  final ValueListenable<List<ActiveRentalModel>> activeRentals;
  final void Function(VehicleModel vehicle, RentalPlan plan) onRent;
  final VoidCallback onOpenActive;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ValueListenableBuilder<VehicleModel?>(
        valueListenable: controller.selected,
        builder: (context, vehicle, _) {
          if (vehicle != null) {
            return VehiclePanelWidget(
              key: ValueKey<String>(vehicle.id),
              controller: controller,
              vehicle: vehicle,
              onRent: onRent,
              onClose: () => controller.select(null),
            );
          }
          return _ActiveRentalsButton(
            activeRentals: activeRentals,
            onPressed: onOpenActive,
          );
        },
      ),
    );
  }
}

class _ActiveRentalsButton extends StatelessWidget {
  const _ActiveRentalsButton({
    required this.activeRentals,
    required this.onPressed,
  });

  final ValueListenable<List<ActiveRentalModel>> activeRentals;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ValueListenableBuilder<List<ActiveRentalModel>>(
          valueListenable: activeRentals,
          builder: (context, rentals, _) {
            final count = rentals.length;
            return FilledButton.icon(
              onPressed: onPressed,
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.directions_car_filled),
              ),
              label: Text(context.tr('active_rentals')),
            );
          },
        ),
      ),
    );
  }
}
