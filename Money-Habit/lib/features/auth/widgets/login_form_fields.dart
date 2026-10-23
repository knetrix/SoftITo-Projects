import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_l10n_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import 'password_field.dart';

class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmitted;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        AppTextField(
          controller: emailController,
          labelText: l10n.emailLabel,
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          validator: (v) => Validators.email(v)?.message(l10n),
        ),
        const SizedBox(height: AppSizes.spaceMd),
        PasswordField(
          controller: passwordController,
          labelText: l10n.passwordLabel,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmitted(),
          validator: (v) => v == null || v.isEmpty ? l10n.errorRequired : null,
        ),
      ],
    );
  }
}
