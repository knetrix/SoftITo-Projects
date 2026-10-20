import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';

/// Panelde tek bilgi hücresi: ikon + etiket + değer (vites, yakıt, fiyat...).
class VehicleInfoRowWidget extends StatelessWidget {
  const VehicleInfoRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
