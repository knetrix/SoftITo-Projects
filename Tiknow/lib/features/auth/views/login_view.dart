import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_text_field_widget.dart';

/// Giriş ekranı. Başarılı girişte kök yönlendirme haritaya geçer; bu ekran
/// yığından kendini kapatır.
class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.auth});

  final AuthController auth;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.auth.clearError();
    final saved = widget.auth.user.value?.email;
    if (saved != null) _email.text = saved;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await widget.auth.login(
      email: _email.text,
      password: _password.text,
    );
    if (ok && mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeaderWidget(
                      titleKey: 'login_title',
                      subtitleKey: 'login_subtitle',
                    ),
                    const SizedBox(height: 28),
                    AuthTextFieldWidget(
                      controller: _email,
                      labelKey: 'email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    AuthTextFieldWidget(
                      controller: _password,
                      labelKey: 'password',
                      icon: Icons.lock_outline,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _submit,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'err_password_required' : null,
                    ),
                    _LoginError(auth: widget.auth),
                    const SizedBox(height: 16),
                    _LoginButton(auth: widget.auth, onPressed: _submit),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(context.tr('no_account_register')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginError extends StatelessWidget {
  const _LoginError({required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: auth.errorKey,
      builder: (context, key, _) {
        if (key == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            context.tr(key),
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.error,
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.auth, required this.onPressed});

  final AuthController auth;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: auth.state,
      builder: (context, state, _) {
        return FilledButton(
          onPressed: state == AuthState.loading ? null : onPressed,
          child: Text(context.tr('login')),
        );
      },
    );
  }
}
