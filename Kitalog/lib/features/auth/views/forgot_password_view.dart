import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/forgot_password_controller.dart';
import '../models/forgot_password_model.dart';
import '../widgets/auth_error_banner_widget.dart';
import '../widgets/auth_page_layout_widget.dart';
import '../widgets/forgot_new_password_form_widget.dart';
import '../widgets/forgot_verify_form_widget.dart';

/// Şifremi unuttum (GEÇİCİ, yerel): kayıtlı e-posta + telefon doğrulanır,
/// yeni şifre belirlenir. Tamamlanınca e-postayla birlikte girişe dönülür.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  ForgotPasswordController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= ForgotPasswordController(auth: AppScope.of(context).authController)
      ..state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = _controller!.state.value;
    if (state.isDone && mounted) Navigator.of(context).pop(state.email);
  }

  @override
  void dispose() {
    _controller?.state.removeListener(_onStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return AuthPageLayoutWidget(
      title: context.l10n.forgotTitle,
      child: ValueListenableBuilder<ForgotPasswordModel>(
        valueListenable: controller.state,
        builder: (context, state, _) => Column(
          children: [
            if (state.error != null) ...[
              AuthErrorBannerWidget(error: state.error!),
              const SizedBox(height: AppSizes.spaceL),
            ],
            if (state.step == ForgotPasswordStep.verify)
              ForgotVerifyFormWidget(
                key: const ValueKey('forgot-verify'),
                isLoading: state.isLoading,
                onSubmit: (email, phone) => controller.verify(email: email, phone: phone),
                onBackToLogin: () => Navigator.of(context).pop(),
              )
            else
              ForgotNewPasswordFormWidget(
                key: const ValueKey('forgot-new-password'),
                email: state.email,
                isLoading: state.isLoading,
                onSubmit: controller.resetPassword,
                onBack: controller.backToVerify,
              ),
          ],
        ),
      ),
    );
  }
}
