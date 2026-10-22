import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;

import '../../l10n/generated/app_localizations.dart';
import '../models/book_model.dart';
import '../models/loan_model.dart';
import '../models/loan_reminder_model.dart';
import '../models/notification_target_model.dart';
import '../repositories/reminders/reminder_engine.dart';
import 'library_controller.dart';
import 'settings_controller.dart';

/// Ödünçteki kitapların iade hatırlatmalarını cihazda zamanlar: iade gününden
/// bir gün önce ve iade günü, saat [reminderHour]'da. Kitap listesi, uygulama
/// dili veya Ayarlar'daki "İade hatırlatmaları" anahtarı değiştikçe plan yeniden
/// hesaplanır; plan aynı kaldıysa (ör. okuma ilerlemesi değişti) bildirimlere
/// dokunulmaz. Motoru hazırlamak ve dokunulan bildirimi ana kabuğa iletmek
/// `NotificationController`'ın işidir; bu sınıf yalnızca [ReminderGroup.loans]'ı kurar.
class LoanReminderController {
  LoanReminderController({
    required this._library,
    required this._settings,
    required this._engine,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const int reminderHour = 10;

  final LibraryController _library;
  final SettingsController _settings;
  final ReminderEngine _engine;
  final DateTime Function() _clock;

  /// Son kurulan planın imzası; `null` ise henüz hiç kurulmadı (açılış).
  String? _lastSignature;
  Set<LoanReminderModel> _lastPlan = const {};
  bool _started = false;

  /// `false` ise (web, masaüstü) Ayarlar'da hatırlatma anahtarı gösterilmez.
  bool get isSupported => _engine.isSupported;

  /// Senkronlar sırayla çalışır; hızlı art arda değişiklikler birbirini ezmez.
  Future<void> _queue = Future.value();

  /// Ödünçteki kitaplar için hatırlatma planı (geçmişte kalanlar hariç), zamana göre sıralı.
  static List<LoanReminderModel> plan(List<BookModel> books, DateTime now) {
    final reminders = <LoanReminderModel>[];
    for (final book in books.where((b) => b.isLent)) {
      final loan = book.loan!;
      final due = loan.dueAt;
      if (due == null) continue;
      final dueDay = DateTime(due.year, due.month, due.day, reminderHour);
      final dayBefore = DateTime(due.year, due.month, due.day - 1, reminderHour);
      // Ödünç verildiği gün "yarın iade" hatırlatması anlamsızdır.
      if (LoanModel.daysBetween(loan.lentAt, dayBefore) >= 1) {
        reminders.add(LoanReminderModel(bookId: book.id, kind: LoanReminderKind.dueTomorrow, scheduledAt: dayBefore));
      }
      reminders.add(LoanReminderModel(bookId: book.id, kind: LoanReminderKind.dueToday, scheduledAt: dueDay));
    }
    return reminders.where((r) => r.scheduledAt.isAfter(now)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Değişiklikleri dinlemeye başlar ve mevcut planı kurar (açılışta izin
  /// istenmez). Motor önceden hazırlanmış olmalıdır (`NotificationController.start`).
  Future<void> start() async {
    if (_started || !_engine.isSupported) return;
    _started = true;
    _library.books.addListener(_onChanged);
    _settings.state.addListener(_onChanged);
    await _enqueue();
  }

  /// Ayarlar'daki anahtar: kaydeder; açılınca bildirim izni istenir.
  /// İzin verilmediyse `false` döner (arayüz kullanıcıyı bilgilendirir).
  Future<bool> setEnabled(bool enabled) async {
    await _settings.setLoanRemindersEnabled(enabled);
    if (!enabled || !_engine.isSupported) return true;
    return _engine.requestPermission();
  }

  void _onChanged() => unawaited(_enqueue());

  Future<void> _enqueue() => _queue = _queue.then((_) => _sync());

  Future<void> _sync() async {
    // Kitaplar henüz yüklenmediyse boş liste "tüm ödünçler iade edildi" sanılmasın.
    if (!_library.isLoaded) return;
    final now = _clock();
    final settings = _settings.state.value;
    final reminders = plan(_library.books.value, now);
    final l10n = lookupAppLocalizations(Locale(settings.localeCode));
    // Anahtar kapalıysa zamanlanmış hatırlatmaların hepsi silinir.
    final notifications = settings.loanRemindersEnabled
        ? [for (final r in reminders) _notification(r, l10n)]
        : const <ScheduledNotification>[];
    final signature = settings.loanRemindersEnabled
        ? notifications.map((n) => '${n.at.toIso8601String()}|${n.title}|${n.body}').join('\n')
        : 'off';
    final plannedNow = reminders.toSet();
    if (signature == _lastSignature) {
      // Anahtar kapalıyken de plan izlenir; yoksa yeniden açınca kapalıyken
      // eklenen ödünç "yeni" sayılıp izin ikinci kez istenirdi.
      _lastPlan = plannedNow;
      return;
    }

    // Kullanıcı yeni bir iade tarihi kaydettiyse (açılıştaki ilk kurulum değil) izin istenir.
    // Plan anahtar kapalıyken de izlenir; yeniden açmak "yeni ödünç" sayılmaz
    // (izni o an Ayarlar ekranı [setEnabled] ile ister).
    final isUserChange = settings.loanRemindersEnabled && _lastSignature != null && !_lastPlan.containsAll(plannedNow);
    _lastSignature = signature;
    _lastPlan = plannedNow;
    if (isUserChange) await _engine.requestPermission();
    await _engine.replaceGroup(ReminderGroup.loans, notifications, (
      name: l10n.loanReminderChannelName,
      description: l10n.loanReminderChannelDescription,
    ));
  }

  ScheduledNotification _notification(LoanReminderModel reminder, AppLocalizations l10n) {
    final book = _library.bookById(reminder.bookId)!;
    return (
      at: reminder.scheduledAt,
      title: switch (reminder.kind) {
        LoanReminderKind.dueTomorrow => l10n.loanReminderTomorrowTitle,
        LoanReminderKind.dueToday => l10n.loanReminderTodayTitle,
      },
      body: l10n.loanReminderBody(book.title, book.loan!.borrowerName),
      payload: NotificationTargetModel.book(book.id).encode(),
    );
  }

  /// Kuyruktaki senkronların bitmesini bekler (testler için).
  @visibleForTesting
  Future<void> get idle => _queue;

  void dispose() {
    if (!_started) return;
    _library.books.removeListener(_onChanged);
    _settings.state.removeListener(_onChanged);
  }
}
