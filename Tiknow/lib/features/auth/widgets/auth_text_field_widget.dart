import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';

/// Etiket/ikon/doğrulama anahtarı alan metin kutusu. Şifre alanlarında
/// göster/gizle düğmesi vardır (yalnızca yerel UI durumu).
class AuthTextFieldWidget extends StatefulWidget {
  const AuthTextFieldWidget({
    super.key,
    required this.controller,
    required this.labelKey,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.obscure = false,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String labelKey;
  final IconData icon;

  /// Hata anahtarı döner (`null` = geçerli); metni bu widget çevirir.
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final VoidCallback? onSubmitted;

  @override
  State<AuthTextFieldWidget> createState() => _AuthTextFieldWidgetState();
}

class _AuthTextFieldWidgetState extends State<AuthTextFieldWidget> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: context.tr(widget.labelKey),
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: context.tr(_hidden ? 'show_password' : 'hide_password'),
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
              )
            : null,
      ),
      validator: (value) {
        final key = widget.validator(value);
        return key == null ? null : context.tr(key);
      },
    );
  }
}
