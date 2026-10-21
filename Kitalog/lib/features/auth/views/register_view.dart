import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/register_controller.dart';
import '../models/auth_form_model.dart';
import '../widgets/auth_page_layout_widget.dart';
import '../widgets/register_form_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  RegisterController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= RegisterController(auth: AppScope.of(context).authController)
      ..state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (_controller!.state.value.isSuccess && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
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
      title: context.l10n.registerTitle,
      child: ValueListenableBuilder<AuthFormModel>(
        valueListenable: controller.state,
        builder: (context, state, _) => RegisterFormWidget(
          isLoading: state.isLoading,
          onSubmit: (email, phone, password) => controller.submit(
            email: email,
            phone: phone,
            password: password,
          ),
          onLoginTap: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        ),
      ),
    );
  }
}
