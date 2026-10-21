import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/phone_input_formatter.dart';
import '../../../core/widgets/user_avatar.dart';

/// Profil resmi ve kullanıcı özeti (e-posta, telefon, üyelik tarihi).
class ProfileSummaryWidget extends StatelessWidget {
  const ProfileSummaryWidget({
    super.key,
    required this.user,
    required this.onAvatarTap,
  });

  final UserModel? user;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = user;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Row(
          children: [
            InkWell(
              onTap: onAvatarTap,
              customBorder: const CircleBorder(),
              child: Tooltip(
                message: l10n.profileChangeAvatar,
                child: UserAvatar(user: current, radius: AppSizes.avatarL / 2),
              ),
            ),
            const SizedBox(width: AppSizes.spaceL),
            Expanded(child: _ProfileInfo(user: current, onAvatarTap: onAvatarTap)),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.user, required this.onAvatarTap});

  final UserModel? user;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(current?.email ?? '', style: context.textTheme.titleMedium),
        Text(
          PhoneInputFormatter.format(current?.phone ?? ''),
          style: context.textTheme.bodyMedium,
        ),
        if (current != null)
          Text(
            l10n.profileMemberSince(context.formatDate(current.createdAt)),
            style: context.textTheme.bodySmall,
          ),
        TextButton.icon(
          onPressed: onAvatarTap,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(l10n.profileChangeAvatar),
        ),
      ],
    );
  }
}
