import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/avatar_picker.dart';
import '../controllers/settings_screen_controller.dart';
import '../models/settings_screen_model.dart';
import '../widgets/settings_body_widget.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, this.avatarPicker});

  /// Testlerde sahte seçici vermek için.
  final AvatarPicker? avatarPicker;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SettingsScreenController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= SettingsScreenController(
      auth: AppScope.of(context).authController,
      avatarPicker: widget.avatarPicker ?? ImagePickerAvatarPicker(),
    )..state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final message = _controller!.state.value.message;
    if (message == null || !mounted) return;
    _controller!.consumeMessage();
    final l10n = context.l10n;
    final text = switch (message) {
      SettingsMessage.emailSaved => l10n.settingsEmailSaved,
      SettingsMessage.phoneSaved => l10n.settingsPhoneSaved,
      SettingsMessage.passwordSaved => l10n.settingsPasswordSaved,
      SettingsMessage.avatarSaved => l10n.settingsAvatarSaved,
      SettingsMessage.avatarFailed => l10n.settingsAvatarFailed,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await _controller!.logout();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  void dispose() {
    _controller?.state.removeListener(_onStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = _controller!;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            scope.settingsController.state,
            scope.authController.state,
            controller.state,
          ]),
          builder: (context, _) => SettingsBodyWidget(
            settings: scope.settingsController.state.value,
            user: scope.authController.user,
            currentPasswordWrong: controller.state.value.currentPasswordWrong,
            cameraAvailable: controller.cameraAvailable,
            onThemeChanged: scope.settingsController.setThemeMode,
            onLocaleChanged: scope.settingsController.setLocaleCode,
            onPresetAvatar: controller.selectPresetAvatar,
            onPickAvatar: controller.pickCustomAvatar,
            onRemoveAvatar: controller.removeAvatar,
            onSaveEmail: controller.saveEmail,
            onSavePhone: controller.savePhone,
            onSavePassword: (current, next) => controller.savePassword(
              currentPassword: current,
              newPassword: next,
            ),
            onPasswordEdited: controller.clearPasswordError,
            onLogout: _logout,
          ),
        ),
      ),
    );
  }
}
