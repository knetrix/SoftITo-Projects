import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_form_fields.dart';

class LoginView extends StatefulWidget {
  final LocalStorageService storage;

  const LoginView({super.key, required this.storage});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(widget.storage);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await _controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loginFailed)),
      );
    }
  }

  Future<void> _handleQuickLogin() async {
    final success = await _controller.quickLogin();
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeader(
                    title: context.l10n.loginTitle,
                    subtitle: context.l10n.appTitle,
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  LoginFormFields(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSubmitted: _handleLogin,
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  ValueListenableBuilder<AuthState>(
                    valueListenable: _controller.state,
                    builder: (context, state, _) {
                      return AppPrimaryButton(
                        label: context.l10n.loginButton,
                        isLoading: state.status == AuthStatus.loading,
                        onPressed: _handleLogin,
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.spaceMd),
                  AppPrimaryButton(
                    label: context.l10n.quickLogin,
                    isOutlined: true,
                    onPressed: _handleQuickLogin,
                  ),
                  const SizedBox(height: AppSizes.spaceMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.dontHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.register),
                        child: Text(context.l10n.registerHere),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
