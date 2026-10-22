import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/app_settings_model.dart';
import 'reading_reminder_tiles_widget.dart';

/// Bildirimler bölümündeki anahtarların ve saat seçiminin geri çağrıları.
typedef NotificationActions = ({
  ValueChanged<bool> onLoanReminders,
  ValueChanged<bool> onReadingReminders,
  ValueChanged<bool> onStalledReminders,
  VoidCallback onPickReadingTime,
});

/// Bildirimler: iade hatırlatmaları, günlük okuma hatırlatması, yarım kalan
/// kitaplar ve okuma hatırlatmalarının saati.
class NotificationSectionWidget extends StatelessWidget {
  const NotificationSectionWidget({super.key, required this.settings, required this.actions});

  final AppSettingsModel settings;
  final NotificationActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.spaceL, AppSizes.spaceS, AppSizes.spaceL, 0),
              child: Text(l10n.settingsNotificationsTitle, style: context.textTheme.titleMedium),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: Text(l10n.settingsLoanReminders),
              subtitle: Text(l10n.settingsLoanRemindersHint),
              value: settings.loanRemindersEnabled,
              onChanged: actions.onLoanReminders,
            ),
            const Divider(indent: AppSizes.spaceL, endIndent: AppSizes.spaceL),
            ReadingReminderTilesWidget(settings: settings, actions: actions),
          ],
        ),
      ),
    );
  }
}
