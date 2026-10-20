import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/money_formatter.dart';
import '../controllers/active_rentals_controller.dart';
import '../models/active_rental_model.dart';
import '../widgets/active_rental_card_widget.dart';
import '../widgets/extend_rental_sheet_widget.dart';

/// Aktif kiralamalar. Controller uygulama geneli olduğundan burada dispose
/// edilmez.
class ActiveRentalsView extends StatelessWidget {
  const ActiveRentalsView({super.key, required this.controller});

  final ActiveRentalsController controller;

  Future<void> _extend(
    BuildContext context,
    ActiveRentalModel rental,
    RentalExtraType type,
  ) async {
    final isMinutes = type == RentalExtraType.minutes;
    final amount = await ExtendRentalSheetWidget.show(
      context,
      rental: rental,
      type: type,
      options: isMinutes
          ? ActiveRentalsController.extendMinuteOptions
          : ActiveRentalsController.addKmOptions,
    );
    if (amount == null || !context.mounted) return;
    final fee = isMinutes
        ? controller.extendTime(rental.id, amount)
        : controller.addKm(rental.id, amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            isMinutes ? 'time_added' : 'km_added',
            args: {'n': '$amount', 'fee': MoneyFormatter.format(fee)},
          ),
        ),
      ),
    );
  }

  Future<void> _finish(BuildContext context, ActiveRentalModel rental) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _FinishConfirmDialog(
        rental: rental,
        now: controller.now.value,
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final summary = controller.finish(rental.id);
    if (summary == null) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _SummaryDialog(rental: rental, summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('active_rentals'))),
      body: SafeArea(
        child: ValueListenableBuilder<List<ActiveRentalModel>>(
          valueListenable: controller.rentals,
          builder: (context, rentals, _) {
            if (rentals.isEmpty) return const _EmptyState();
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rentals.length,
              itemBuilder: (context, i) {
                final rental = rentals[i];
                return ActiveRentalCardWidget(
                  key: ValueKey<String>(rental.id),
                  rental: rental,
                  now: controller.now,
                  onExtendTime: () =>
                      _extend(context, rental, RentalExtraType.minutes),
                  onAddKm: () => _extend(context, rental, RentalExtraType.km),
                  onFinish: () => _finish(context, rental),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_crash_outlined, size: 72, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              context.tr('no_active_rentals'),
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('no_active_rentals_hint'),
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(context.tr('back_to_map')),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinishConfirmDialog extends StatelessWidget {
  const _FinishConfirmDialog({required this.rental, required this.now});

  final ActiveRentalModel rental;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final summary = rental.summaryAt(now);
    return AlertDialog(
      title: Text(context.tr('finish_rental')),
      content: Text(
        context.tr(
          'finish_confirm',
          args: {'total': MoneyFormatter.format(summary.total)},
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.tr('finish')),
        ),
      ],
    );
  }
}

class _SummaryDialog extends StatelessWidget {
  const _SummaryDialog({required this.rental, required this.summary});

  final ActiveRentalModel rental;
  final RentalSummary summary;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.check_circle, color: context.colors.primary, size: 40),
      title: Text(context.tr('rental_finished')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryLine(
            label: context.tr('base_fee'),
            value: MoneyFormatter.format(summary.baseFee),
          ),
          _SummaryLine(
            label: context.tr('overage_total'),
            value: MoneyFormatter.format(summary.overageFee),
          ),
          _SummaryLine(
            label: context.tr('extras_total'),
            value: MoneyFormatter.format(summary.extrasFee),
          ),
          const Divider(),
          _SummaryLine(
            label: context.tr('grand_total'),
            value: MoneyFormatter.format(summary.total),
            bold: true,
          ),
        ],
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('ok')),
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = context.textStyles.bodyLarge?.copyWith(
      fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
  }
}
