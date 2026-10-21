import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/avatar_picker.dart';

/// Hazır avatarlar, galeri/kamera ve kaldırma seçenekleri.
class AvatarOptionsSheet extends StatelessWidget {
  const AvatarOptionsSheet({
    super.key,
    required this.cameraAvailable,
    required this.onPreset,
    required this.onPick,
    required this.onRemove,
  });

  final bool cameraAvailable;
  final ValueChanged<String> onPreset;
  final ValueChanged<AvatarSource> onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.avatarPresetTitle, style: context.textTheme.titleMedium),
            const SizedBox(height: AppSizes.spaceM),
            _PresetGrid(onPreset: onPreset),
            const SizedBox(height: AppSizes.spaceM),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.avatarFromGallery),
              onTap: () => onPick(AvatarSource.gallery),
            ),
            if (cameraAvailable)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.avatarFromCamera),
                onTap: () => onPick(AvatarSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.avatarRemove),
              onTap: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetAvatarButton extends StatelessWidget {
  const _PresetAvatarButton({required this.avatarKey, required this.onTap});

  final String avatarKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: avatarKey,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: CircleAvatar(
          radius: AppSizes.avatarS,
          backgroundImage: AssetImage(AppAssets.avatarPath(avatarKey)),
        ),
      ),
    );
  }
}

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({required this.onPreset});

  final ValueChanged<String> onPreset;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spaceM,
      runSpacing: AppSizes.spaceM,
      children: [
        for (final key in AppAssets.presetAvatarKeys)
          _PresetAvatarButton(avatarKey: key, onTap: () => onPreset(key)),
      ],
    );
  }
}
