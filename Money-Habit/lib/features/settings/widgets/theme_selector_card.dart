import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

class ThemeSelectorCard extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;

  const ThemeSelectorCard({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
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
              l10n.settingsTheme,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(l10n.settingsThemeDark),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(l10n.settingsThemeLight),
                ),
              ],
              selected: {currentMode},
              onSelectionChanged: (newSelection) {
                if (newSelection.isNotEmpty) {
                  onModeChanged(newSelection.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
