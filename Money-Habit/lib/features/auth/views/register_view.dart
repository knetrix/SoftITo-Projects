import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/register_form_fields.dart';

class RegisterView extends StatefulWidget {
  final LocalStorageService storage;

  const RegisterView({super.key, required this.storage});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(widget.storage);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await _controller.register(
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } else {
      final errorKey = _controller.state.value.errorMessage;
      final message = errorKey == 'userAlreadyExists'
          ? context.l10n.userAlreadyExists
          : context.l10n.loginFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                    title: context.l10n.registerTitle,
                    subtitle: context.l10n.appTitle,
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  RegisterFormFields(
                    emailController: _emailController,
                    phoneController: _phoneController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                  ),
                  const SizedBox(height: AppSizes.spaceLg),
                  ValueListenableBuilder<AuthState>(
                    valueListenable: _controller.state,
                    builder: (context, state, _) {
                      return AppPrimaryButton(
                        label: context.l10n.registerButton,
                        isLoading: state.status == AuthStatus.loading,
                        onPressed: _handleRegister,
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
                        context.l10n.alreadyHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                        child: Text(context.l10n.loginHere),
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
