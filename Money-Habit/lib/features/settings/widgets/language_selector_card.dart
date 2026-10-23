import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

class LanguageSelectorCard extends StatelessWidget {
  final String currentLocale;
  final ValueChanged<String> onLocaleChanged;

  const LanguageSelectorCard({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsLanguage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'tr',
                  label: Text(l10n.settingsLangTr),
                ),
                ButtonSegment<String>(
                  value: 'en',
                  label: Text(l10n.settingsLangEn),
                ),
              ],
              selected: {currentLocale},
              onSelectionChanged: (newSelection) {
                if (newSelection.isNotEmpty) {
                  onLocaleChanged(newSelection.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
