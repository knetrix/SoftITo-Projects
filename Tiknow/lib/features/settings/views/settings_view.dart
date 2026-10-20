import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/app_dependencies.dart';
import '../controllers/profile_controller.dart';
import '../widgets/language_selector_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/theme_selector_widget.dart';
import 'change_email_view.dart';
import 'change_password_view.dart';
import 'change_phone_view.dart';

/// Ayarlar: profil, tema, dil, hesap değişiklikleri ve çıkış.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final ProfileController _profile;

  @override
  void initState() {
    super.initState();
    _profile = ProfileController(widget.deps.auth);
  }

  @override
  void dispose() {
    _profile.dispose();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _logout() async {
    await widget.deps.auth.logout();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileHeaderWidget(profile: _profile.profile),
            const SizedBox(height: 20),
            _SectionTitle(titleKey: 'theme'),
            ThemeSelectorWidget(settings: widget.deps.settings),
            const SizedBox(height: 20),
            _SectionTitle(titleKey: 'language'),
            LanguageSelectorWidget(settings: widget.deps.settings),
            const SizedBox(height: 20),
            _SectionTitle(titleKey: 'account'),
            _AccountTiles(
              onEmail: () => _open(ChangeEmailView(controller: _profile)),
              onPhone: () => _open(ChangePhoneView(controller: _profile)),
              onPassword: () => _open(ChangePasswordView(controller: _profile)),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(context.tr('logout')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.titleKey});

  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        context.tr(titleKey),
        style: context.textStyles.titleSmall?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AccountTiles extends StatelessWidget {
  const _AccountTiles({
    required this.onEmail,
    required this.onPhone,
    required this.onPassword,
  });

  final VoidCallback onEmail;
  final VoidCallback onPhone;
  final VoidCallback onPassword;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(context.tr('change_email')),
            trailing: const Icon(Icons.chevron_right),
            onTap: onEmail,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(context.tr('change_phone')),
            trailing: const Icon(Icons.chevron_right),
            onTap: onPhone,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(context.tr('change_password')),
            trailing: const Icon(Icons.chevron_right),
            onTap: onPassword,
          ),
        ],
      ),
    );
  }
}
