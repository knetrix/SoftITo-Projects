import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_input_field.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';

class RegisterView extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onRegisterSuccess;

  const RegisterView({
    super.key,
    required this.authController,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await widget.authController.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pop();
      widget.onRegisterSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeaderWidget(
                  title: AppStrings.registerTitle,
                  subtitle: AppStrings.registerSubtitle,
                ),
                const SizedBox(height: 24),
                _buildInputFields(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.alreadyHaveAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        AuthInputField(
          controller: _nameController,
          label: AppStrings.nameLabel,
          hint: 'Adınız Soyadınız',
          prefixIcon: Icons.person_outline_rounded,
          validator: AppValidators.validateName,
        ),
        const SizedBox(height: 14),
        AuthInputField(
          controller: _emailController,
          label: AppStrings.emailLabel,
          hint: AppStrings.emailHint,
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: AppValidators.validateEmail,
        ),
        const SizedBox(height: 14),
        AuthInputField(
          controller: _phoneController,
          label: AppStrings.phoneLabel,
          hint: AppStrings.phoneHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: AppValidators.validatePhone,
        ),
        const SizedBox(height: 14),
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
          onPressed: isLoading ? null : _submitRegister,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(AppStrings.registerButton),
        );
      },
    );
  }
}
