import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_text_field_widget.dart';
import 'login_view.dart';

/// Kayıt ekranı. Başarılı kayıtta `AuthController.state` değişir ve kök
/// yönlendirme haritaya geçer.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.auth});

  final AuthController auth;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.auth.clearError();
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.auth.register(
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
      passwordConfirm: _confirm.text,
    );
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginView(auth: widget.auth)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      titleKey: 'register_title',
                      subtitleKey: 'register_subtitle',
                    ),
                    const SizedBox(height: 28),
                    ..._fields(),
                    _ErrorText(auth: widget.auth),
                    const SizedBox(height: 8),
                    _SubmitButton(auth: widget.auth, onPressed: _submit),
                    const SizedBox(height: 8),
                    if (widget.auth.hasAccount)
                      TextButton(
                        onPressed: _openLogin,
                        child: Text(context.tr('have_account_login')),
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

  List<Widget> _fields() {
    return [
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
        controller: _phone,
        labelKey: 'phone',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        validator: Validators.phone,
      ),
      const SizedBox(height: 14),
      AuthTextFieldWidget(
        controller: _password,
        labelKey: 'password',
        icon: Icons.lock_outline,
        obscure: true,
        validator: Validators.password,
      ),
      const SizedBox(height: 14),
      AuthTextFieldWidget(
        controller: _confirm,
        labelKey: 'password_confirm',
        icon: Icons.lock_reset,
        obscure: true,
        textInputAction: TextInputAction.done,
        onSubmitted: _submit,
        validator: (v) => Validators.passwordConfirm(v, _password.text),
      ),
    ];
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.auth});

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

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.auth, required this.onPressed});

  final AuthController auth;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: auth.state,
      builder: (context, state, _) {
        return FilledButton(
          onPressed: state == AuthState.loading ? null : onPressed,
          child: Text(context.tr('register')),
        );
      },
    );
  }
}
