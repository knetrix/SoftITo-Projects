import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/app_settings_model.dart';

/// Tema (Karanlık / Aydınlık) ve dil (Türkçe / English) seçimi; anında uygulanır.
class AppearanceSectionWidget extends StatelessWidget {
  const AppearanceSectionWidget({
    super.key,
    required this.settings,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  final AppSettingsModel settings;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<String> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSizes.spaceM,
          children: [
            Text(l10n.settingsThemeTitle, style: context.textTheme.titleMedium),
            _ThemeSelector(mode: settings.themeMode, onChanged: onThemeChanged),
            Text(l10n.settingsLanguageTitle, style: context.textTheme.titleMedium),
            _LanguageSelector(code: settings.localeCode, onChanged: onLocaleChanged),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: ThemeMode.dark,
          icon: const Icon(Icons.dark_mode_outlined),
          label: Text(l10n.themeDark),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: const Icon(Icons.light_mode_outlined),
          label: Text(l10n.themeLight),
        ),
      ],
      selected: {mode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.code, required this.onChanged});

  final String code;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: 'tr', label: Text(l10n.languageTurkish)),
        ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
      ],
      selected: {code},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}
