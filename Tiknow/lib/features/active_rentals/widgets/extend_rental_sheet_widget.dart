import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/money_formatter.dart';
import '../models/active_rental_model.dart';

/// Süre uzat / km ekle seçim sayfası. Seçilen miktar ile kapanır
/// (iptalde `null`).
class ExtendRentalSheetWidget extends StatelessWidget {
  const ExtendRentalSheetWidget({
    super.key,
    required this.rental,
    required this.type,
    required this.options,
  });

  final ActiveRentalModel rental;
  final RentalExtraType type;
  final List<int> options;

  static Future<int?> show(
    BuildContext context, {
    required ActiveRentalModel rental,
    required RentalExtraType type,
    required List<int> options,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => ExtendRentalSheetWidget(
        rental: rental,
        type: type,
        options: options,
      ),
    );
  }

  bool get _isMinutes => type == RentalExtraType.minutes;

  double _unitPrice() {
    final package = rental.package;
    if (package == null) return 0;
    return _isMinutes ? package.extraPerMinute : package.extraPerKm;
  }

  @override
  Widget build(BuildContext context) {
    final unit = context.tr(_isMinutes ? 'unit_min' : 'unit_km');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr(_isMinutes ? 'extend_time' : 'add_km'),
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr(
                'extend_note',
                args: {'rate': MoneyFormatter.rate(_unitPrice(), unit)},
              ),
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final amount in options)
              _OptionTile(
                label: '+$amount $unit',
                fee: MoneyFormatter.format(amount * _unitPrice()),
                onTap: () => Navigator.of(context).pop(amount),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.fee,
    required this.onTap,
  });

  final String label;
  final String fee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          minVerticalPadding: 12,
          title: Text(
            label,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          trailing: Text(
            fee,
            style: context.textStyles.titleSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
