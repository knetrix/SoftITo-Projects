import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../extensions/validation_extensions.dart';
import '../utils/validators.dart';

/// Kayıt, Giriş ve Ayarlar'da ortak kullanılan e-posta alanı.
class EmailFormField extends StatelessWidget {
  const EmailFormField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: l10n.fieldEmail,
        prefixIcon: const Icon(Icons.mail_outline),
      ),
      validator: (value) => Validators.email(value)?.message(l10n),
    );
  }
}
