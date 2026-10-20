import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../models/profile_model.dart';

/// Ayarlar üstündeki profil kartı: baş harf, e-posta ve telefon.
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key, required this.profile});

  final ValueListenable<ProfileModel> profile;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfileModel>(
      valueListenable: profile,
      builder: (context, value, _) {
        final scheme = context.colors;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: Text(
                    value.initial,
                    style: context.textStyles.titleLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _ProfileLines(profile: value)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileLines extends StatelessWidget {
  const _ProfileLines({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          profile.displayPhone,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
