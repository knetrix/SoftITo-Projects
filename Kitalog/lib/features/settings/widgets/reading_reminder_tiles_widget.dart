import 'package:flutter/material.dart';

import '../../../core/controllers/reading_reminder_controller.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/app_settings_model.dart';
import 'notification_section_widget.dart';

/// Okuma hatırlatmaları: günlük davet, yarım kalan kitaplar ve ortak saat.
/// Saat satırı ikisinden biri açıkken etkindir.
class ReadingReminderTilesWidget extends StatelessWidget {
  const ReadingReminderTilesWidget({super.key, required this.settings, required this.actions});

  final AppSettingsModel settings;
  final NotificationActions actions;

  String _time(BuildContext context) {
    final minutes = settings.readingReminderMinutes;
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.auto_stories_outlined),
          title: Text(l10n.settingsReadingReminders),
          subtitle: Text(l10n.settingsReadingRemindersHint),
          value: settings.readingRemindersEnabled,
          onChanged: actions.onReadingReminders,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.hourglass_bottom_outlined),
          title: Text(l10n.settingsStalledReminders),
          subtitle: Text(l10n.settingsStalledRemindersHint(ReadingReminderController.stalledAfterDays)),
          value: settings.stalledBookRemindersEnabled,
          onChanged: actions.onStalledReminders,
        ),
        ListTile(
          leading: const Icon(Icons.schedule_outlined),
          title: Text(l10n.settingsReadingReminderTime),
          trailing: Text(_time(context), style: context.textTheme.titleMedium),
          enabled: settings.anyReadingReminderEnabled,
          onTap: actions.onPickReadingTime,
        ),
      ],
    );
  }
}
