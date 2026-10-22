import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_input_field.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLoginSuccess;

  const LoginView({
    super.key,
    required this.authController,
    required this.onLoginSuccess,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'melih@rutino.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await widget.authController.login(
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeaderWidget(
                    title: AppStrings.loginTitle,
                    subtitle: AppStrings.loginSubtitle,
                  ),
                  const SizedBox(height: 32),
                  _buildFormFields(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 12),
                  _buildGuestButton(),
                  const SizedBox(height: 20),
                  _buildRegisterNavigation(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        AuthInputField(
          controller: _emailController,
          label: AppStrings.emailLabel,
          hint: AppStrings.emailHint,
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: AppValidators.validateEmail,
        ),
        const SizedBox(height: 16),
        AuthInputField(
          controller: _passwordController,
          label: AppStrings.passwordLabel,
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          keyboardType: TextInputType.visiblePassword,
          validator: AppValidators.validatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.authController.isLoadingNotifier,
      builder: (context, isLoading, _) {
        return ElevatedButton(
          onPressed: isLoading ? null : _submitLogin,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(AppStrings.loginButton),
        );
      },
    );
  }

  Widget _buildGuestButton() {
    return OutlinedButton(
      onPressed: () async {
        await widget.authController.guestLogin();
        if (mounted) widget.onLoginSuccess();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(AppStrings.guestButton),
    );
  }

  Widget _buildRegisterNavigation() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RegisterView(
              authController: widget.authController,
              onRegisterSuccess: widget.onLoginSuccess,
            ),
          ),
        );
      },
      child: Text(AppStrings.doNotHaveAccount),
    );
  }
}
