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
              key: const ValueKey('login-form'),
              isLoading: state.isLoading,
              onSubmit: (email, password) =>
                  controller.submit(email: email, password: password),
              onRegisterTap: () =>
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.register),
            ),
          ],
        ),
      ),
    );
  }
}
