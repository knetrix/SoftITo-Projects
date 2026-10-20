import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../rental_packages/models/rental_package_model.dart';
import '../models/vehicle_model.dart';

/// "Dakikalık" veya bir paketi seçtiren yatay kart listesi.
class PackageSelectorWidget extends StatelessWidget {
  const PackageSelectorWidget({
    super.key,
    required this.vehicle,
    required this.selected,
    required this.onSelected,
  });

  final VehicleModel vehicle;
  final RentalPlan selected;
  final ValueChanged<RentalPlan> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _PlanCard(
            title: context.tr('plan_per_minute'),
            subtitle: MoneyFormatter.rate(
              vehicle.pricePerMinute,
              context.tr('unit_min'),
            ),
            selected: selected.isPerMinute,
            onTap: () => onSelected(const RentalPlan.perMinute()),
          ),
          for (final p in RentalPackageModel.all)
            _PlanCard(
              title: context.tr(p.nameKey),
              subtitle: '${MoneyFormatter.format(p.price)}\n${_detail(context, p)}',
              selected: selected.packageId == p.id,
              onTap: () => onSelected(RentalPlan.package(p.id)),
            ),
        ],
      ),
    );
  }

  String _detail(BuildContext context, RentalPackageModel p) {
    final time = DurationFormatter.minutes(
      p.minutes,
      hourUnit: context.tr('unit_hour'),
      minuteUnit: context.tr('unit_min'),
    );
    return '$time · ${p.km} ${context.tr('unit_km')}';
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selected,
        label: '$title, $subtitle',
        excludeSemantics: true,
        child: Material(
          color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 112, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: context.textStyles.titleSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: context.textStyles.bodySmall?.copyWith(color: fg),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
