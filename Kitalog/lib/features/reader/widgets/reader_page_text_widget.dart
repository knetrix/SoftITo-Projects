import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../models/reader_translation_model.dart';

/// Sayfa metni: orijinal, yalnızca çeviri veya her satırın altında çevirisi.
/// Çeviri henüz hazır değilse ([translatedLines] `null`) orijinal gösterilir.
/// Tek bir `Text` olduğu için seçim (ve alıntı / çeviri menüsü) sayfanın
/// tamamında çalışır.
class ReaderPageTextWidget extends StatelessWidget {
  const ReaderPageTextWidget({
    super.key,
    required this.text,
    required this.view,
    this.translatedLines,
  });

  final String text;
  final TranslationView view;
  final List<String>? translatedLines;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyLarge;
    final lines = translatedLines;
    if (lines == null || view == TranslationView.original) {
      return Text(text, style: style);
    }
    if (view == TranslationView.translation) {
      return Text(lines.join('\n'), style: style);
    }
    final translationStyle = style?.copyWith(
      color: context.colors.primary,
      fontStyle: FontStyle.italic,
    );
    final originals = text.split('\n');
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (var i = 0; i < originals.length; i++) ...[
            TextSpan(text: originals[i]),
            if (i < lines.length && lines[i].isNotEmpty)
              TextSpan(text: '\n${lines[i]}', style: translationStyle),
            if (i < originals.length - 1) const TextSpan(text: '\n'),
          ],
        ],
      ),
    );
  }
}
