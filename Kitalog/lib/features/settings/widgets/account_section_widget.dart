import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/user_model.dart';
import 'email_update_form_widget.dart';
import 'password_update_form_widget.dart';
import 'phone_update_form_widget.dart';

/// Hesap bilgileri: e-posta, telefon ve şifre güncelleme (açılır bölümler).
class AccountSectionWidget extends StatelessWidget {
  const AccountSectionWidget({
    super.key,
    required this.user,
    required this.currentPasswordWrong,
    required this.onSaveEmail,
    required this.onSavePhone,
    required this.onSavePassword,
    required this.onPasswordEdited,
  });

  final UserModel user;
  final bool currentPasswordWrong;
  final Future<bool> Function(String email) onSaveEmail;
  final Future<bool> Function(String phoneDigits) onSavePhone;
  final Future<bool> Function(String current, String next) onSavePassword;
  final VoidCallback onPasswordEdited;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _Section(
            icon: Icons.mail_outline,
            title: l10n.settingsUpdateEmail,
            child: EmailUpdateFormWidget(
              key: ValueKey(user.email),
              initialEmail: user.email,
              onSave: onSaveEmail,
            ),
          ),
          _Section(
            icon: Icons.phone_outlined,
            title: l10n.settingsUpdatePhone,
            child: PhoneUpdateFormWidget(
              key: ValueKey(user.phone),
              initialPhone: user.phone,
              onSave: onSavePhone,
            ),
          ),
          _Section(
            icon: Icons.lock_outline,
            title: l10n.settingsUpdatePassword,
            child: PasswordUpdateFormWidget(
              currentPasswordWrong: currentPasswordWrong,
              onSave: onSavePassword,
              onEdited: onPasswordEdited,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.fromLTRB(
        AppSizes.spaceL,
        0,
        AppSizes.spaceL,
        AppSizes.spaceL,
      ),
      children: [child],
    );
  }
}
