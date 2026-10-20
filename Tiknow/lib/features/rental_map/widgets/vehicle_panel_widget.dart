import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/money_formatter.dart';
import '../../rental_packages/models/rental_package_model.dart';
import '../controllers/rental_map_controller.dart';
import '../models/vehicle_model.dart';
import 'package_selector_widget.dart';
import 'vehicle_image_widget.dart';
import 'vehicle_info_row_widget.dart';

/// Seçili aracın alt paneli: yürüme süresi, fotoğraf, model-plaka, vites,
/// yakıt, fiyat ve paket seçimi. "Kirala" ile ödeme akışı başlar.
class VehiclePanelWidget extends StatelessWidget {
  const VehiclePanelWidget({
    super.key,
    required this.controller,
    required this.vehicle,
    required this.onRent,
    required this.onClose,
  });

  final RentalMapController controller;
  final VehicleModel vehicle;
  final void Function(VehicleModel vehicle, RentalPlan plan) onRent;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: scheme.surface,
      elevation: 8,
      shadowColor: scheme.shadow,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PanelHeader(
                walkingMinutes: controller.walkingMinutesTo(vehicle),
                onClose: onClose,
              ),
              _VehicleSummary(vehicle: vehicle),
              const SizedBox(height: 12),
              _PlanSection(
                controller: controller,
                vehicle: vehicle,
                onRent: onRent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.walkingMinutes, required this.onClose});

  final int walkingMinutes;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Row(
      children: [
        Icon(Icons.directions_walk, color: scheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            context.tr('walking_minutes', args: {'n': '$walkingMinutes'}),
            style: context.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: context.tr('close'),
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VehicleImageWidget(
          url: vehicle.imageUrl,
          semanticLabel: vehicle.model,
          width: 132,
          height: 96,
        ),
        const SizedBox(width: 12),
        Expanded(child: _VehicleDetails(vehicle: vehicle)),
      ],
    );
  }
}

class _VehicleDetails extends StatelessWidget {
  const _VehicleDetails({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          vehicle.model,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          vehicle.plate,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        VehicleInfoRowWidget(
          icon: Icons.settings,
          label: context.tr('gear'),
          value: context.tr(vehicle.isAutomatic ? 'gear_auto' : 'gear_manual'),
        ),
        VehicleInfoRowWidget(
          icon: vehicle.fuelType == FuelType.electric
              ? Icons.bolt
              : Icons.local_gas_station,
          label: context.tr(vehicle.fuelType.levelKey),
          value: '%${vehicle.fuelPercent} · '
              '${context.tr(vehicle.fuelType.labelKey)}',
        ),
        VehicleInfoRowWidget(
          icon: Icons.payments_outlined,
          label: context.tr('price'),
          value: MoneyFormatter.rate(
            vehicle.pricePerMinute,
            context.tr('unit_min'),
          ),
        ),
      ],
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({
    required this.controller,
    required this.vehicle,
    required this.onRent,
  });

  final RentalMapController controller;
  final VehicleModel vehicle;
  final void Function(VehicleModel vehicle, RentalPlan plan) onRent;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RentalPlan>(
      valueListenable: controller.plan,
      builder: (context, plan, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PackageSelectorWidget(
              vehicle: vehicle,
              selected: plan,
              onSelected: controller.selectPlan,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => onRent(vehicle, plan),
              child: Text(_buttonLabel(context, plan)),
            ),
          ],
        );
      },
    );
  }

  String _buttonLabel(BuildContext context, RentalPlan plan) {
    final package = plan.package;
    if (package == null) return context.tr('rent_per_minute');
    return context.tr(
      'rent_package',
      args: {'price': MoneyFormatter.format(package.price)},
    );
  }
}
