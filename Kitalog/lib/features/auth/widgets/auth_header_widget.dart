import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.auto_stories_rounded,
          size: AppSizes.iconL,
          color: context.colors.primary,
        ),
        const SizedBox(height: AppSizes.spaceL),
        Text(title, style: context.textTheme.headlineMedium),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          context.l10n.authTagline,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
