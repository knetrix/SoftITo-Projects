import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/validators.dart';
import '../models/payment_model.dart';

/// Test kartı formu. Yalnızca yerel form durumu (controller'lar, form anahtarı)
/// burada tutulur; ödeme akışı `PaymentController`'dadır.
class CardFormWidget extends StatefulWidget {
  const CardFormWidget({
    super.key,
    required this.state,
    required this.submitLabel,
    required this.onSubmit,
  });

  final ValueListenable<PaymentState> state;
  final String submitLabel;
  final ValueChanged<PaymentModel> onSubmit;

  @override
  State<CardFormWidget> createState() => _CardFormWidgetState();
}

class _CardFormWidgetState extends State<CardFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _holder = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  @override
  void dispose() {
    _number.dispose();
    _holder.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(
      PaymentModel(
        cardNumber: _number.text,
        holderName: _holder.text.trim(),
        expiry: _expiry.text,
        cvv: _cvv.text,
      ),
    );
  }

  String? _msg(String? key) => key == null ? null : context.tr(key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _number,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [_DigitsFormatter(16, groupBy: 4, separator: ' ')],
            decoration: InputDecoration(
              labelText: context.tr('card_number'),
              prefixIcon: const Icon(Icons.credit_card),
            ),
            validator: (v) => _msg(Validators.cardNumber(v)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _holder,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.tr('card_holder'),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (v) => _msg(Validators.required(v)),
          ),
          const SizedBox(height: 12),
          _expiryAndCvv(context),
          const SizedBox(height: 16),
          _SubmitButton(
            state: widget.state,
            label: widget.submitLabel,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _expiryAndCvv(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _expiry,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [_DigitsFormatter(4, groupBy: 2, separator: '/')],
            decoration: InputDecoration(
              labelText: context.tr('card_expiry'),
              hintText: 'AA/YY',
            ),
            validator: (v) => _msg(Validators.cardExpiry(v)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _cvv,
            keyboardType: TextInputType.number,
            obscureText: true,
            inputFormatters: [_DigitsFormatter(3)],
            decoration: InputDecoration(labelText: context.tr('card_cvv')),
            validator: (v) => _msg(Validators.cvv(v)),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.state,
    required this.label,
    required this.onPressed,
  });

  final ValueListenable<PaymentState> state;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaymentState>(
      valueListenable: state,
      builder: (context, value, _) {
        final busy = value == PaymentState.processing ||
            value == PaymentState.success;
        return FilledButton(
          onPressed: busy ? null : onPressed,
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(label),
        );
      },
    );
  }
}

/// Yalnızca rakam kabul eder, [maxDigits] ile sınırlar ve [groupBy] hanede
/// bir [separator] ekler.
class _DigitsFormatter extends TextInputFormatter {
  _DigitsFormatter(this.maxDigits, {this.groupBy = 0, this.separator = ''});

  final int maxDigits;
  final int groupBy;
  final String separator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (groupBy > 0 && i > 0 && i % groupBy == 0) buffer.write(separator);
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
