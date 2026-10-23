import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../auth/models/user_model.dart';
import 'user_avatar_widget.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onAvatarTap;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final phone = user?.phone != null ? Validators.formatPhone(user!.phone) : '';
    final regDate = user?.createdAt.formatDate(locale) ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Row(
          children: [
            UserAvatarWidget(
              user: user,
              radius: AppSizes.avatarMd / 2,
              onTap: onAvatarTap,
              showEditBadge: true,
            ),
            const SizedBox(width: AppSizes.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spaceXs),
                    Text(
                      phone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (regDate.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spaceXs),
                    Text(
                      context.l10n.settingsRegisteredAt(regDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
