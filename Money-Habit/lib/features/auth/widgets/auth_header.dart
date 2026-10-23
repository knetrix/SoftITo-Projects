import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary, width: 2),
          ),
          child: Icon(
            Icons.savings_rounded,
            size: 36,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSizes.spaceMd),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
