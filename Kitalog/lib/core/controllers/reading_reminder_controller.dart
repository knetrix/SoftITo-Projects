import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;

import '../../l10n/generated/app_localizations.dart';
import '../models/app_settings_model.dart';
import '../models/book_model.dart';
import '../models/notification_target_model.dart';
import '../models/reading_log_entry_model.dart';
import '../models/reading_reminder_model.dart';
import '../models/reading_status.dart';
import '../repositories/reminders/reminder_engine.dart';
import 'library_controller.dart';
import 'settings_controller.dart';

/// Okuma hatırlatmalarını cihazda zamanlar ([ReminderGroup.reading]):
/// - Günlük davet: önümüzdeki [windowDays] gün, Ayarlar'daki saatte; o gün
///   okuma ilerlemesi kaydedildiyse o günün daveti atlanır. Dün ve öncesinde
///   art arda en az [minStreakDays] gün okunduysa davet seri metniyle gider.
/// - Yarım kalan kitap: "Okunuyor" kitapta [stalledAfterDays] gün ilerleme
///   yoksa o günün saatinde bir kez; aynı günün günlük davetinin yerini alır.
/// Günlük bildirim sistemde tekrarlanmaz; tek seferlik bildirimler her açılışta
/// ve her değişiklikte ileri kaydırılır (saat dilimi paketi gerekmez, uygulamayı
/// uzun süre açmayana sonsuza kadar bildirim gitmez).
class ReadingReminderController {
  ReadingReminderController({
    required this._library,
    required this._settings,
    required this._engine,
    DateTime Function()? clock,
    this.textRefreshDelay = const Duration(seconds: 2),
  }) : _clock = clock ?? DateTime.now;

  static const int windowDays = 7;
  static const int stalledAfterDays = 14;
  static const int minStreakDays = 2;

  final LibraryController _library;
  final SettingsController _settings;
  final ReminderEngine _engine;
  final DateTime Function() _clock;

  /// Plan aynı kalıp yalnızca metin değiştiğinde (ör. okuyucuda sayfa çevirmek
  /// "sayfa N" metnini değiştirir) bildirimler bu kadar bekleyip bir kez kurulur.
  final Duration textRefreshDelay;

  String? _lastSignature;
  List<ReadingReminderModel> _lastPlan = const [];
  bool _started = false;
  Timer? _textRefresh;
  Future<void> _queue = Future.value();

  bool get isSupported => _engine.isSupported;

  /// Okuma hatırlatması planı (geçmişte kalanlar hariç), zamana göre sıralı.
  static List<ReadingReminderModel> plan({
    required List<BookModel> books,
    required List<ReadingLogEntryModel> log,
    required AppSettingsModel settings,
    required DateTime now,
  }) {
    final today = ReadingLogEntryModel.dayOf(now);
    final minutes = settings.readingReminderMinutes;
    DateTime at(DateTime day) => DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
    DateTime addDays(DateTime day, int days) => DateTime(day.year, day.month, day.day + days);

    final readDays = {for (final e in log) e.day};
    final reading = books.where((b) => b.status == ReadingStatus.reading).toList();
    final lastActivity = {for (final b in reading) b.id: _lastActivity(b, log)};
    // En son ilerlenen kitap günlük davetin konusu olur.
    reading.sort((a, b) => lastActivity[b.id]!.compareTo(lastActivity[a.id]!));

    final reminders = <ReadingReminderModel>[];
    if (settings.stalledBookRemindersEnabled) {
      for (final book in reading) {
        final when = at(addDays(lastActivity[book.id]!, stalledAfterDays));
        if (when.isAfter(now)) {
          reminders.add(ReadingReminderModel(kind: ReadingReminderKind.stalled, scheduledAt: when, bookId: book.id));
        }
      }
    }
    if (settings.readingRemindersEnabled) {
      final stalledDays = {for (final r in reminders) ReadingLogEntryModel.dayOf(r.scheduledAt)};
      for (var d = 0; d < windowDays; d++) {
        final day = addDays(today, d);
        final when = at(day);
        if (!when.isAfter(now) || stalledDays.contains(day)) continue;
        if (day == today && readDays.contains(today)) continue;
        final streak = _streakBefore(day, readDays);
        reminders.add(ReadingReminderModel(
          kind: streak >= minStreakDays ? ReadingReminderKind.streak : ReadingReminderKind.daily,
          scheduledAt: when,
          bookId: reading.firstOrNull?.id,
          streakDays: streak >= minStreakDays ? streak : 0,
        ));
      }
    }
    return reminders..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Kitapta son ilerlenen gün; kayıt yoksa başlama (o da yoksa ekleme) günü.
  static DateTime _lastActivity(BookModel book, List<ReadingLogEntryModel> log) {
    var last = ReadingLogEntryModel.dayOf(book.startedAt ?? book.addedAt);
    for (final e in log) {
      if (e.bookId == book.id && e.day.isAfter(last)) last = e.day;
    }
    return last;
  }

  /// [day]'den önceki günlerden geriye doğru art arda okunan gün sayısı. Gelecek
  /// günler kayıtta olmadığı için yarından sonraki davetlerde seri 0 olur.
  static int _streakBefore(DateTime day, Set<DateTime> readDays) {
    var count = 0;
    var cursor = DateTime(day.year, day.month, day.day - 1);
    while (readDays.contains(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }

  /// Değişiklikleri dinlemeye başlar ve mevcut planı kurar (izin istenmez).
  Future<void> start() async {
    if (_started || !_engine.isSupported) return;
    _started = true;
    _library.books.addListener(_onChanged);
    _library.readingLog.addListener(_onChanged);
    _settings.state.addListener(_onChanged);
    await _enqueue();
  }

  /// Ayarlar'daki "Günlük okuma hatırlatması" anahtarı; açılınca bildirim izni
  /// istenir. İzin verilmediyse `false` döner (arayüz kullanıcıyı bilgilendirir).
  Future<bool> setDailyEnabled(bool enabled) async {
    await _settings.setReadingRemindersEnabled(enabled);
    return enabled ? _requestPermission() : true;
  }

  /// Ayarlar'daki "Yarım kalan kitaplar" anahtarı; [setDailyEnabled] gibi.
  Future<bool> setStalledEnabled(bool enabled) async {
    await _settings.setStalledBookRemindersEnabled(enabled);
    return enabled ? _requestPermission() : true;
  }

  Future<void> setTime(int minutes) => _settings.setReadingReminderMinutes(minutes);

  Future<bool> _requestPermission() async => !_engine.isSupported || await _engine.requestPermission();

  List<ReadingReminderModel> _currentPlan() => plan(
    books: _library.books.value,
    log: _library.readingLog.value,
    settings: _settings.state.value,
    now: _clock(),
  );

  void _onChanged() {
    _textRefresh?.cancel();
    if (!_library.isLoaded) return;
    // Plan değiştiyse (ör. bugün ilk kez okundu, anahtar kapandı) hemen; yalnızca
    // metin değiştiyse kısa bir beklemeden sonra kurulur.
    if (!listEquals(_currentPlan(), _lastPlan)) {
      unawaited(_enqueue());
    } else {
      _textRefresh = Timer(textRefreshDelay, () => unawaited(_enqueue()));
    }
  }

  Future<void> _enqueue() => _queue = _queue.then((_) => _sync());

  Future<void> _sync() async {
    if (!_library.isLoaded) return;
    final reminders = _currentPlan();
    final l10n = lookupAppLocalizations(Locale(_settings.state.value.localeCode));
    final notifications = [for (final r in reminders) _notification(r, l10n)];
    final signature = notifications.map((n) => '${n.at.toIso8601String()}|${n.title}|${n.body}|${n.payload}').join('\n');
    _lastPlan = reminders;
    if (signature == _lastSignature) return;
    _lastSignature = signature;
    await _engine.replaceGroup(ReminderGroup.reading, notifications, (
      name: l10n.readingReminderChannelName,
      description: l10n.readingReminderChannelDescription,
    ));
  }

  ScheduledNotification _notification(ReadingReminderModel reminder, AppLocalizations l10n) {
    final book = reminder.bookId == null ? null : _library.bookById(reminder.bookId!);
    if (book == null) {
      return (
        at: reminder.scheduledAt,
        title: l10n.readingReminderTitle,
        body: l10n.readingReminderBodyNoBook,
        payload: const NotificationTargetModel.readingStatus().encode(),
      );
    }
    final invite = book.currentPage > 0
        ? l10n.readingReminderBody(book.title, book.currentPage)
        : l10n.readingReminderBodyStart(book.title);
    final (title, body) = switch (reminder.kind) {
      ReadingReminderKind.daily => (l10n.readingReminderTitle, invite),
      ReadingReminderKind.streak => (l10n.readingReminderStreakTitle(reminder.streakDays), invite),
      ReadingReminderKind.stalled => (
        l10n.readingReminderStalledTitle,
        l10n.readingReminderStalledBody(book.title, stalledAfterDays),
      ),
    };
    return (at: reminder.scheduledAt, title: title, body: body, payload: NotificationTargetModel.read(book.id).encode());
  }

  /// Bekleyen metin yenilemesini hemen çalıştırır ve kuyruğun bitmesini bekler (testler için).
  @visibleForTesting
  Future<void> get idle {
    if (_textRefresh?.isActive ?? false) {
      _textRefresh!.cancel();
      unawaited(_enqueue());
    }
    return _queue;
  }

  void dispose() {
    _textRefresh?.cancel();
    if (!_started) return;
    _library.books.removeListener(_onChanged);
    _library.readingLog.removeListener(_onChanged);
    _settings.state.removeListener(_onChanged);
  }
}
