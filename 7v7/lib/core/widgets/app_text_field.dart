import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import 'icon_circle_button.dart';

/// Alan `field` (§2.9): etiket üstte 14/700, 52 yükseklik, köşe 16,
/// `card` zemin, 1.5 `line`; hata: `error` kontur + uyarı ikonu + 14/600.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.controller,
    this.error,
    this.hint,
    this.placeholder,
    this.password = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.prefixIcon,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  });

  final String? label;
  final TextEditingController? controller;
  final String? error;
  final String? hint;
  final String? placeholder;
  final bool password;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final hasError = widget.error != null;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: hasError ? c.error : c.line, width: 1.5),
    );
    final field = SizedBox(
      height: 52,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.password && _obscure,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofillHints: widget.autofillHints,
        inputFormatters: widget.inputFormatters,
        textCapitalization: widget.textCapitalization,
        autocorrect: false,
        enableSuggestions: !widget.password,
        style: AppTextStyles.body(400, color: c.ink),
        cursorColor: c.ink,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: c.card,
          hintText: widget.placeholder,
          hintStyle: AppTextStyles.body(400, color: c.ink2),
          contentPadding: EdgeInsets.fromLTRB(
            widget.prefixIcon != null ? 48 : 16,
            14,
            widget.password ? 56 : 16,
            14,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: hasError ? c.error : c.ink2,
              width: 1.5,
            ),
          ),
          prefixIcon: widget.prefixIcon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 16, right: 10),
                  child: Icon(widget.prefixIcon, size: 22, color: c.ink2),
                ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 48, minHeight: 22),
          suffixIcon: widget.password
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconCircleButton(
                    variant: IconButtonVariant.plain,
                    icon: _obscure
                        ? PhosphorIconsFill.eye
                        : PhosphorIconsFill.eyeSlash,
                    semanticLabel: _obscure ? l.showPw : l.hidePw,
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 48, minHeight: 44),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.bodySm(700, color: c.ink)),
          const SizedBox(height: 6),
        ],
        field,
        if (hasError) ...[
          const SizedBox(height: 6),
          FieldError(widget.error!),
        ] else if (widget.hint != null) ...[
          const SizedBox(height: 6),
          Text(widget.hint!, style: AppTextStyles.bodySm(400, color: c.ink2)),
        ],
      ],
    );
  }
}

/// Hata satırı (§2.9 `err`): uyarı ikonu 18 + 14/600 `error` metin.
class FieldError extends StatelessWidget {
  const FieldError(this.text, {super.key, this.weight = 600});
  final String text;
  final int weight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(PhosphorIconsFill.warningCircle,
                size: 18, color: c.error),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm(weight, color: c.error),
            ),
          ),
        ],
      ),
    );
  }
}
