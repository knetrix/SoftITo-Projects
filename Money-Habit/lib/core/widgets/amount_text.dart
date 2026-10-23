import 'package:flutter/material.dart';

import '../extensions/money_extensions.dart';

class AmountText extends StatelessWidget {
  final int amount; // kuruş
  final TextStyle? style;
  final Color? color;
  final String? prefix;
  final String? suffix;

  const AmountText({
    super.key,
    required this.amount,
    this.style,
    this.color,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final formatted = amount.toCurrency(localeCode);
    final text = '${prefix ?? ''}$formatted${suffix ?? ''}';

    final textStyle = (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
      color: color,
    );

    return Text(text, style: textStyle);
  }
}
