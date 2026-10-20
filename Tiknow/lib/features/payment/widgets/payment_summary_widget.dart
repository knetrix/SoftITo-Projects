import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../rental_map/models/vehicle_model.dart';
import '../../rental_map/widgets/vehicle_image_widget.dart';
import '../../rental_packages/models/rental_package_model.dart';

/// Ödeme öncesi araç + plan özeti ve şimdi ödenecek tutar.
class PaymentSummaryWidget extends StatelessWidget {
  const PaymentSummaryWidget({
    super.key,
    required this.vehicle,
    required this.plan,
  });

  final VehicleModel vehicle;
  final RentalPlan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _VehicleHeader(vehicle: vehicle),
            const Divider(height: 24),
            _PlanLines(vehicle: vehicle, plan: plan),
            const Divider(height: 24),
            _PayNowRow(plan: plan),
          ],
        ),
      ),
    );
  }
}

class _VehicleHeader extends StatelessWidget {
  const _VehicleHeader({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VehicleImageWidget(
          url: vehicle.imageUrl,
          semanticLabel: vehicle.model,
          width: 88,
          height: 64,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.model,
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${vehicle.plate} · ${vehicle.district}',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanLines extends StatelessWidget {
  const _PlanLines({required this.vehicle, required this.plan});

  final VehicleModel vehicle;
  final RentalPlan plan;

  @override
  Widget build(BuildContext context) {
    final package = plan.package;
    if (package == null) {
      return Column(
        children: [
          _Line(
            label: context.tr('plan'),
            value: context.tr('plan_per_minute'),
          ),
          _Line(
            label: context.tr('price'),
            value: MoneyFormatter.rate(
              vehicle.pricePerMinute,
              context.tr('unit_min'),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        _Line(label: context.tr('plan'), value: context.tr(package.nameKey)),
        _Line(
          label: context.tr('duration'),
          value: DurationFormatter.minutes(
            package.minutes,
            hourUnit: context.tr('unit_hour'),
            minuteUnit: context.tr('unit_min'),
          ),
        ),
        _Line(
          label: context.tr('km_allowance'),
          value: '${package.km} ${context.tr('unit_km')}',
        ),
        _Line(
          label: context.tr('overage_per_km'),
          value: MoneyFormatter.rate(package.extraPerKm, context.tr('unit_km')),
        ),
        _Line(
          label: context.tr('overage_per_min'),
          value: MoneyFormatter.rate(
            package.extraPerMinute,
            context.tr('unit_min'),
          ),
        ),
      ],
    );
  }
}

class _PayNowRow extends StatelessWidget {
  const _PayNowRow({required this.plan});

  final RentalPlan plan;

  @override
  Widget build(BuildContext context) {
    final package = plan.package;
    final scheme = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Line(
          label: context.tr('pay_now'),
          value: MoneyFormatter.format(package?.price ?? 0),
          emphasized: true,
        ),
        if (package == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              context.tr('per_minute_note'),
              style: context.textStyles.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: context.colors.primary,
          )
        : context.textStyles.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(value, style: style?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
