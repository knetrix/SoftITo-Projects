import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/local_storage_service.dart';
import '../../auth/models/user_model.dart';
import '../controllers/settings_controller.dart';
import '../models/app_settings_model.dart';
import '../widgets/account_update_bottom_sheet.dart';
import '../widgets/avatar_picker_bottom_sheet.dart';
import '../widgets/language_selector_card.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/theme_selector_card.dart';

class SettingsView extends StatefulWidget {
  final LocalStorageService storage;
  final SettingsController settingsController;

  const SettingsView({
    super.key,
    required this.storage,
    required this.settingsController,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    widget.settingsController.refreshUser();
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AvatarPickerBottomSheet(
        onAvatarSelected: (avatar) {
          widget.settingsController.updateAvatar(avatar);
        },
      ),
    );
  }

  void _showAccountUpdate(UserModel user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AccountUpdateBottomSheet(
        user: user,
        controller: widget.settingsController,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settingsLogout),
        content: Text(context.l10n.settingsLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.settingsLogout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.storage.setLoggedIn(false);
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<UserModel?>(
          valueListenable: widget.settingsController.currentUser,
          builder: (context, user, _) {
            return ValueListenableBuilder<AppSettingsModel>(
              valueListenable: widget.settingsController.state,
              builder: (context, settings, _) {
                return ListView(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  children: [
                    ProfileHeaderCard(
                      user: user,
                      onAvatarTap: _showAvatarPicker,
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    if (user != null)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.manage_accounts_outlined),
                          title: Text(l10n.settingsAccountUpdate),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showAccountUpdate(user),
                        ),
                      ),
                    const SizedBox(height: AppSizes.spaceMd),
                    ThemeSelectorCard(
                      currentMode: settings.themeMode,
                      onModeChanged: widget.settingsController.setThemeMode,
                    ),
                    const SizedBox(height: AppSizes.spaceMd),
                    LanguageSelectorCard(
                      currentLocale: settings.localeCode,
                      onLocaleChanged: widget.settingsController.setLocaleCode,
                    ),
                    const SizedBox(height: AppSizes.spaceLg),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.settingsLogout),
                      onPressed: _handleLogout,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
