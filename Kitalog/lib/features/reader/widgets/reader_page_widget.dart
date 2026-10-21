import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Tek bir okuma sayfası. Yazı boyutu `TextScaler` ile uygulanır; sayfa kendi
/// içinde kaydırılabildiği için büyük yazıda taşma olmaz.
class ReaderPageWidget extends StatelessWidget {
  const ReaderPageWidget({
    super.key,
    required this.text,
    required this.textScale,
  });

  final String text;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(media.textScaler.scale(1) * textScale),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spaceXl,
          AppSizes.spaceL,
          AppSizes.spaceXl,
          AppSizes.spaceXl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.readerMaxWidth),
            child: SelectionArea(
              child: Text(text, style: context.textTheme.bodyLarge),
            ),
          ),
        ),
      ),
    );
  }
}
