import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Tek değerli istatistik kartı (örn. toplam okunan sayfa).
class GoalStatCardWidget extends StatelessWidget {
  const GoalStatCardWidget({
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Row(
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(child: Text(label, style: context.textTheme.bodyMedium)),
            Text(value, style: context.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
