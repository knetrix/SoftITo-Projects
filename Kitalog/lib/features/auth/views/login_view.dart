import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/login_controller.dart';
import '../models/auth_form_model.dart';
import '../widgets/auth_error_banner_widget.dart';
import '../widgets/auth_page_layout_widget.dart';
import '../widgets/login_form_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  LoginController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= LoginController(auth: AppScope.of(context).authController)
      ..state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (_controller!.state.value.isSuccess && mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  /// Şifre sıfırlanınca ekran e-postayla döner: form doldurulur ve bilgi verilir.
  Future<void> _openForgotPassword() async {
    final email = await Navigator.of(context).pushNamed<String>(AppRoutes.forgotPassword);
    if (email == null || !mounted) return;
    _controller!.passwordWasReset(email);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.forgotSuccess)));
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
      title: context.l10n.loginTitle,
      child: ValueListenableBuilder<AuthFormModel>(
        valueListenable: controller.state,
        builder: (context, state, _) => Column(
          children: [
            if (state.error != null) ...[
              AuthErrorBannerWidget(error: state.error!),
              const SizedBox(height: AppSizes.spaceL),
            ],
            LoginFormWidget(
              key: ValueKey('login-form-${state.prefillEmail ?? ''}'),
              initialEmail: state.prefillEmail,
              isLoading: state.isLoading,
              onSubmit: (email, password) =>
                  controller.submit(email: email, password: password),
              onRegisterTap: () =>
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.register),
              onForgotPasswordTap: _openForgotPassword,
            ),
          ],
        ),
      ),
    );
  }
}
