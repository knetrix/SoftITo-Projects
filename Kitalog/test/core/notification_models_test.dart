import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/app_settings_model.dart';
import 'package:kitalog/core/models/notification_target_model.dart';
import 'package:kitalog/core/models/reading_log_entry_model.dart';
import 'package:kitalog/core/models/reading_reminder_model.dart';
import 'package:kitalog/core/repositories/reminders/reminder_engine.dart';

void main() {
  group('NotificationTargetModel', () {
    test('hedef payload olarak yazılıp geri okunur', () {
      for (final target in const [
        NotificationTargetModel.book('seed-1'),
        NotificationTargetModel.read('kitap:iki'),
        NotificationTargetModel.readingStatus(),
      ]) {
        expect(NotificationTargetModel.parse(target.encode()), target);
        expect(NotificationTargetModel.fromJson(target.toJson()), target);
      }
      expect(const NotificationTargetModel.read('x').encode(), 'read:x');
      expect(const NotificationTargetModel.readingStatus().encode(), 'readingStatus');
    });

    test('önceki sürümün düz kitap kimliği Kitap Detay sayılır; boş payload yok sayılır', () {
      expect(NotificationTargetModel.parse('seed-9781979064927'), const NotificationTargetModel.book('seed-9781979064927'));
      expect(NotificationTargetModel.parse(''), isNull);
      expect(NotificationTargetModel.parse(null), isNull);
      expect(NotificationTargetModel.parse('read:'), isNull);
    });
  });

  test('ReadingLogEntryModel günü gece yarısına yuvarlar ve JSON gidiş-dönüşü', () {
    final entry = ReadingLogEntryModel(bookId: 'b', day: DateTime(2026, 10, 22, 18, 45), pages: 12);
    expect(entry.day, DateTime(2026, 10, 22));
    expect(entry.toJson()['day'], '2026-10-22');
    expect(ReadingLogEntryModel.fromJson(entry.toJson()), entry);
    expect(entry.copyWith(pages: 3).pages, 3);
  });

  test('ReadingReminderModel JSON gidiş-dönüşü', () {
    final model = ReadingReminderModel(
      kind: ReadingReminderKind.streak,
      scheduledAt: DateTime(2026, 10, 22, 21),
      bookId: 'b',
      streakDays: 4,
    );
    expect(ReadingReminderModel.fromJson(model.toJson()), model);
    expect(model.copyWith(kind: ReadingReminderKind.daily).kind, ReadingReminderKind.daily);
  });

  test('okuma hatırlatmaları varsayılan kapalı, saat 21:00; geçersiz saat varsayılana düşer', () {
    const settings = AppSettingsModel();
    expect(settings.readingRemindersEnabled, isFalse);
    expect(settings.stalledBookRemindersEnabled, isFalse);
    expect(settings.anyReadingReminderEnabled, isFalse);
    expect(settings.readingReminderMinutes, 21 * 60);

    final old = AppSettingsModel.fromJson(const {'themeMode': 'dark', 'loanRemindersEnabled': false});
    expect(old.readingRemindersEnabled, isFalse, reason: 'eski kayıtta alan yoksa kapalı');
    expect(AppSettingsModel.fromJson(const {'readingReminderMinutes': 5000}).readingReminderMinutes, 21 * 60);
    expect(settings.copyWith(readingReminderMinutes: -1).readingReminderMinutes, 21 * 60);

    final changed = settings.copyWith(
      readingRemindersEnabled: true,
      stalledBookRemindersEnabled: true,
      readingReminderMinutes: 450,
    );
    final restored = AppSettingsModel.fromJson(changed.toJson());
    expect(restored.readingRemindersEnabled, isTrue);
    expect(restored.stalledBookRemindersEnabled, isTrue);
    expect(restored.readingReminderMinutes, 450);
    expect(restored.anyReadingReminderEnabled, isTrue);
  });

  test('bildirim grupları ayrık kimlik aralıkları ve ayrı kanallar kullanır', () {
    expect(ReminderGroup.loans.owns(1), isTrue, reason: 'önceki sürümün kimlikleri iade grubunda kalır');
    expect(ReminderGroup.loans.owns(ReminderGroup.reading.firstId), isFalse);
    expect(ReminderGroup.reading.owns(ReminderGroup.reading.firstId), isTrue);
    expect(ReminderGroup.reading.owns(ReminderGroup.loans.firstId + ReminderGroup.capacity - 1), isFalse);
    expect(ReminderGroup.loans.channelId, isNot(ReminderGroup.reading.channelId));
  });
}
