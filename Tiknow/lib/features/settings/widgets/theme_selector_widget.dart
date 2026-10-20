import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/settings_controller.dart';

/// Sistem / Açık / Koyu tema seçici.
class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settings.themeMode,
      builder: (context, mode, _) {
        return SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto),
                label: Text(context.tr('theme_system')),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode),
                label: Text(context.tr('theme_light')),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode),
                label: Text(context.tr('theme_dark')),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (s) => settings.setThemeMode(s.first),
          ),
        );
      },
    );
  }
}
