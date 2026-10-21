import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/app_settings_model.dart';
import '../../../core/models/user_model.dart';
import '../controllers/avatar_picker.dart';
import 'account_section_widget.dart';
import 'appearance_section_widget.dart';
import 'avatar_options_sheet.dart';
import 'profile_summary_widget.dart';

/// Ayarlar ekranının kaydırılabilir gövdesi.
class SettingsBodyWidget extends StatelessWidget {
  const SettingsBodyWidget({
    super.key,
    required this.settings,
    required this.user,
    required this.currentPasswordWrong,
    required this.cameraAvailable,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.onPresetAvatar,
    required this.onPickAvatar,
    required this.onRemoveAvatar,
    required this.onSaveEmail,
    required this.onSavePhone,
    required this.onSavePassword,
    required this.onPasswordEdited,
    required this.onLogout,
  });

  final AppSettingsModel settings;
  final UserModel? user;
  final bool currentPasswordWrong;
  final bool cameraAvailable;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<String> onLocaleChanged;
  final ValueChanged<String> onPresetAvatar;
  final ValueChanged<AvatarSource> onPickAvatar;
  final VoidCallback onRemoveAvatar;
  final Future<bool> Function(String email) onSaveEmail;
  final Future<bool> Function(String phoneDigits) onSavePhone;
  final Future<bool> Function(String current, String next) onSavePassword;
  final VoidCallback onPasswordEdited;
  final VoidCallback onLogout;

  void _openAvatarSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        void closeThen(VoidCallback action) {
          Navigator.of(sheetContext).pop();
          action();
        }

        return AvatarOptionsSheet(
          cameraAvailable: cameraAvailable,
          onPreset: (key) => closeThen(() => onPresetAvatar(key)),
          onPick: (source) => closeThen(() => onPickAvatar(source)),
          onRemove: () => closeThen(onRemoveAvatar),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceL),
      child: Column(
        spacing: AppSizes.spaceM,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSummaryWidget(
            user: current,
            onAvatarTap: () => _openAvatarSheet(context),
          ),
          AppearanceSectionWidget(
            settings: settings,
            onThemeChanged: onThemeChanged,
            onLocaleChanged: onLocaleChanged,
          ),
          if (current != null)
            AccountSectionWidget(
              user: current,
              currentPasswordWrong: currentPasswordWrong,
              onSaveEmail: onSaveEmail,
              onSavePhone: onSavePhone,
              onSavePassword: onSavePassword,
              onPasswordEdited: onPasswordEdited,
            ),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            label: Text(context.l10n.settingsLogout),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsLogoutTitle),
        content: Text(l10n.settingsLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.settingsLogout),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onLogout();
  }
}
