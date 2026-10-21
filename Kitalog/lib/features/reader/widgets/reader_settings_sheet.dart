import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/app_settings_model.dart';

/// Okuyucu yazı boyutu ayarı (alt panel).
class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({
    super.key,
    required this.textScale,
    required this.onChanged,
  });

  final double textScale;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.readerTextSize, style: context.textTheme.titleMedium),
            Row(
              children: [
                const Icon(Icons.text_decrease, size: AppSizes.iconS),
                Expanded(
                  child: Slider(
                    value: textScale,
                    min: AppSettingsModel.minReaderTextScale,
                    max: AppSettingsModel.maxReaderTextScale,
                    divisions: 10,
                    label: l10n.readerTextScaleValue((textScale * 100).round()),
                    onChanged: onChanged,
                  ),
                ),
                const Icon(Icons.text_increase),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
