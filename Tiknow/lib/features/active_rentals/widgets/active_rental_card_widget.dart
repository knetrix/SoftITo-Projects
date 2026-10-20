import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../models/active_rental_model.dart';
import 'rental_usage_bar_painter.dart';

/// Tek aktif kiralama kartı. Saniyelik sayaç yalnızca [now] dinleyen
/// alt widget'ları yeniler.
class ActiveRentalCardWidget extends StatelessWidget {
  const ActiveRentalCardWidget({
    super.key,
    required this.rental,
    required this.now,
    required this.onExtendTime,
    required this.onAddKm,
    required this.onFinish,
  });

  final ActiveRentalModel rental;
  final ValueListenable<DateTime> now;
  final VoidCallback onExtendTime;
  final VoidCallback onAddKm;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardHeader(rental: rental),
            const SizedBox(height: 12),
            ValueListenableBuilder<DateTime>(
              valueListenable: now,
              builder: (context, time, _) => _UsageSection(
                rental: rental,
                time: time,
              ),
            ),
            const SizedBox(height: 12),
            _Actions(
              rental: rental,
              onExtendTime: onExtendTime,
              onAddKm: onAddKm,
              onFinish: onFinish,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.rental});

  final ActiveRentalModel rental;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final package = rental.package;
    return Row(
      children: [
        Icon(Icons.directions_car_filled, color: scheme.primary, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rental.vehicle.model,
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${rental.vehicle.plate} · '
                '${context.tr(package?.nameKey ?? 'plan_per_minute')}',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsageSection extends StatelessWidget {
  const _UsageSection({required this.rental, required this.time});

  final ActiveRentalModel rental;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final summary = rental.summaryAt(time);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (rental.isPerMinute)
          _PerMinuteInfo(rental: rental, time: time)
        else
          _PackageUsage(rental: rental, time: time),
        const SizedBox(height: 12),
        _FeeRow(
          label: context.tr('current_total'),
          value: MoneyFormatter.format(summary.total),
        ),
        if (!rental.isPerMinute && summary.extrasFee > 0)
          _FeeRow(
            label: context.tr('extras_total'),
            value: MoneyFormatter.format(summary.extrasFee),
          ),
        if (summary.overageFee > 0)
          _FeeRow(
            label: context.tr('overage_total'),
            value: MoneyFormatter.format(summary.overageFee),
            isWarning: true,
          ),
      ],
    );
  }
}

class _PerMinuteInfo extends StatelessWidget {
  const _PerMinuteInfo({required this.rental, required this.time});

  final ActiveRentalModel rental;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('elapsed_time'),
          style: context.textStyles.bodySmall,
        ),
        Text(
          DurationFormatter.clock(rental.elapsedSeconds(time)),
          style: context.textStyles.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          MoneyFormatter.rate(
            rental.vehicle.pricePerMinute,
            context.tr('unit_min'),
          ),
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PackageUsage extends StatelessWidget {
  const _PackageUsage({required this.rental, required this.time});

  final ActiveRentalModel rental;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final remaining = rental.remainingSeconds(time);
    final overtime = remaining < 0;
    final km = rental.usedKm(time);
    final kmOver = km > rental.includedKm;
    final scheme = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _UsageLine(
          label: context.tr(overtime ? 'time_over' : 'remaining_time'),
          value: '${overtime ? '+' : ''}${DurationFormatter.clock(remaining)}',
          ratio: rental.elapsedSeconds(time) / (rental.includedMinutes * 60),
          color: overtime ? scheme.error : scheme.primary,
          bold: true,
        ),
        const SizedBox(height: 12),
        _UsageLine(
          label: context.tr('km_used'),
          value: '$km / ${rental.includedKm} ${context.tr('unit_km')}',
          ratio: rental.includedKm == 0 ? 1 : km / rental.includedKm,
          color: kmOver ? scheme.error : scheme.primary,
        ),
      ],
    );
  }
}

class _UsageLine extends StatelessWidget {
  const _UsageLine({
    required this.label,
    required this.value,
    required this.ratio,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final double ratio;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final valueStyle = bold
        ? context.textStyles.headlineSmall
        : context.textStyles.titleMedium;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textStyles.bodySmall),
          Text(
            value,
            style: valueStyle?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 10,
            width: double.infinity,
            child: CustomPaint(
              painter: RentalUsageBarPainter(
                ratio: ratio,
                fillColor: color,
                trackColor: context.colors.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  final String label;
  final String value;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? context.colors.error : null;
    final style = context.textStyles.bodyMedium?.copyWith(color: color);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(value, style: style?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.rental,
    required this.onExtendTime,
    required this.onAddKm,
    required this.onFinish,
  });

  final ActiveRentalModel rental;
  final VoidCallback onExtendTime;
  final VoidCallback onAddKm;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!rental.isPerMinute)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onExtendTime,
                  icon: const Icon(Icons.more_time),
                  label: Text(context.tr('extend_time')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddKm,
                  icon: const Icon(Icons.add_road),
                  label: Text(context.tr('add_km')),
                ),
              ),
            ],
          ),
        if (!rental.isPerMinute) const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onFinish,
          icon: const Icon(Icons.flag),
          label: Text(context.tr('finish_rental')),
        ),
      ],
    );
  }
}
