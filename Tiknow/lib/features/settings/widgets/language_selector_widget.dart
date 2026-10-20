import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/settings_controller.dart';

/// Türkçe / English dil seçici. Değişim `MaterialApp`'e anında yansır.
class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: settings.locale,
      builder: (context, locale, _) {
        return SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: 'tr',
                label: Text(context.tr('language_tr')),
              ),
              ButtonSegment(
                value: 'en',
                label: Text(context.tr('language_en')),
              ),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (s) => settings.setLocale(Locale(s.first)),
          ),
        );
      },
    );
  }
}
