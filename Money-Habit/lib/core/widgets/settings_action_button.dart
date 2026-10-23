import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../router/app_router.dart';

class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.settingsTitle,
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
    );
  }
}
