import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_l10n_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import 'password_field.dart';

class RegisterFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegisterFormFields({
    super.key,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
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
        AppTextField(
          controller: phoneController,
          labelText: l10n.phoneLabel,
          hintText: '5XX XXX XX XX',
          prefixIcon: const Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: (v) => Validators.phone(v)?.message(l10n),
        ),
        const SizedBox(height: AppSizes.spaceMd),
        PasswordField(
          controller: passwordController,
          labelText: l10n.passwordLabel,
          textInputAction: TextInputAction.next,
          validator: (v) => Validators.password(v)?.message(l10n),
        ),
        const SizedBox(height: AppSizes.spaceMd),
        PasswordField(
          controller: confirmPasswordController,
          labelText: l10n.confirmPasswordLabel,
          textInputAction: TextInputAction.done,
          validator: (v) =>
              Validators.confirmPassword(v, passwordController.text)?.message(l10n),
        ),
      ],
    );
  }
}
