import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../auth/models/user_model.dart';
import '../../settings/widgets/user_avatar_widget.dart';

class DashboardWelcomeHeader extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onAvatarTap;

  const DashboardWelcomeHeader({
    super.key,
    required this.user,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final email = user?.email ?? '';
    final name = email.contains('@') ? email.split('@').first : email;

    return Row(
      children: [
        UserAvatarWidget(
          user: user,
          radius: AppSizes.avatarSm,
          onTap: onAvatarTap,
        ),
        const SizedBox(width: AppSizes.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboardWelcome,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                name.isNotEmpty ? name : l10n.appTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
