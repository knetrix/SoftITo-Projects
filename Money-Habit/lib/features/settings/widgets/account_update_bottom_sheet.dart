import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_l10n_extension.dart';
import '../../../core/utils/password_hasher.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/models/user_model.dart';
import '../../auth/widgets/password_field.dart';
import '../controllers/settings_controller.dart';

class AccountUpdateBottomSheet extends StatefulWidget {
  final UserModel user;
  final SettingsController controller;

  const AccountUpdateBottomSheet({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  State<AccountUpdateBottomSheet> createState() => _AccountUpdateBottomSheetState();
}

class _AccountUpdateBottomSheetState extends State<AccountUpdateBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Verify current password
    if (!PasswordHasher.verify(
      _currentPasswordController.text,
      widget.user.passwordHash,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorIncorrectPassword)),
      );
      return;
    }

    setState(() => _isLoading = true);

    String newPasswordHash = widget.user.passwordHash;
    if (_newPasswordController.text.isNotEmpty) {
      newPasswordHash = PasswordHasher.hash(_newPasswordController.text);
    }

    final updated = widget.user.copyWith(
      email: _emailController.text.trim(),
      phone: Validators.normalizePhone(_phoneController.text),
      passwordHash: newPasswordHash,
    );

    await widget.controller.updateUser(updated);

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsUpdateSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.p24,
        right: AppSizes.p24,
        top: AppSizes.p24,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.p24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsAccountUpdate,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceLg),
              AppTextField(
                controller: _emailController,
                labelText: l10n.emailLabel,
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => Validators.email(v)?.message(l10n),
              ),
              const SizedBox(height: AppSizes.spaceMd),
              AppTextField(
                controller: _phoneController,
                labelText: l10n.phoneLabel,
                prefixIcon: const Icon(Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (v) => Validators.phone(v)?.message(l10n),
              ),
              const SizedBox(height: AppSizes.spaceMd),
              PasswordField(
                controller: _currentPasswordController,
                labelText: l10n.settingsCurrentPassword,
                validator: (v) => v == null || v.isEmpty ? l10n.errorRequired : null,
              ),
              const SizedBox(height: AppSizes.spaceMd),
              PasswordField(
                controller: _newPasswordController,
                labelText: l10n.settingsNewPassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  return Validators.password(v)?.message(l10n);
                },
              ),
              const SizedBox(height: AppSizes.spaceLg),
              AppPrimaryButton(
                label: l10n.commonSave,
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
