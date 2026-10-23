import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../auth/models/avatar_model.dart';

class AvatarPickerBottomSheet extends StatelessWidget {
  final ValueChanged<AvatarModel> onAvatarSelected;

  const AvatarPickerBottomSheet({
    super.key,
    required this.onAvatarSelected,
  });

  static const List<String> presetAvatars = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
  ];

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 400, maxHeight: 400);
    if (picked == null || !context.mounted) return;

    String path = picked.path;
    if (!kIsWeb) {
      final appDir = await getApplicationDocumentsDirectory();
      final targetPath = '${appDir.path}/avatar_${DateTime.now().microsecondsSinceEpoch}.png';
      final saved = await File(picked.path).copy(targetPath);
      path = saved.path;
    }

    onAvatarSelected(AvatarModel(type: AvatarType.file, value: path));
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsPickAvatar,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceLg),
            Text(
              l10n.settingsAvatarPreset,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final asset in presetAvatars)
                  GestureDetector(
                    onTap: () {
                      onAvatarSelected(AvatarModel(type: AvatarType.preset, value: asset));
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      radius: AppSizes.avatarSm,
                      backgroundImage: AssetImage(asset),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceLg),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.settingsAvatarGallery),
              onPressed: () => _pickImage(context, ImageSource.gallery),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(l10n.settingsAvatarCamera),
              onPressed: () => _pickImage(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
