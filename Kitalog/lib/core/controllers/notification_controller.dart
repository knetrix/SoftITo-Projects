import 'package:flutter/foundation.dart';

import '../models/notification_target_model.dart';
import '../repositories/reminders/reminder_engine.dart';
import 'loan_reminder_controller.dart';
import 'reading_reminder_controller.dart';

/// Bildirim motorunu bir kez hazırlar, ardından iade ve okuma hatırlatmalarının
/// planlarını başlatır. Dokunulan bildirimin hedefi [pendingTarget] ile ana
/// kabuğa iletilir; oturum kapalıyken gelirse girişten sonraya kadar bekler.
class NotificationController {
  NotificationController({
    required this._engine,
    required this.loanReminders,
    required this.readingReminders,
  });

  final ReminderEngine _engine;
  final LoanReminderController loanReminders;
  final ReadingReminderController readingReminders;
  bool _started = false;

  /// Dokunulan bildirimin hedefi; ana kabuk açıp [takePendingTarget] ile tüketir.
  final ValueNotifier<NotificationTargetModel?> pendingTarget = ValueNotifier<NotificationTargetModel?>(null);

  /// `false` ise (web, masaüstü) Ayarlar'da Bildirimler bölümü gösterilmez.
  bool get isSupported => _engine.isSupported;

  /// Açılışta bir kez çağrılır (`main.dart`); izin istemez.
  Future<void> start() async {
    if (_started || !_engine.isSupported) return;
    _started = true;
    await _engine.initialize(onOpen: _open);
    final launchedFrom = await _engine.launchPayload();
    if (launchedFrom != null) _open(launchedFrom);
    await loanReminders.start();
    await readingReminders.start();
  }

  void _open(String payload) {
    final target = NotificationTargetModel.parse(payload);
    if (target != null) pendingTarget.value = target;
  }

  /// Bekleyen hedefi döndürür ve temizler (bir kez açılsın diye).
  NotificationTargetModel? takePendingTarget() {
    final target = pendingTarget.value;
    pendingTarget.value = null;
    return target;
  }

  /// Planlayıcılar `AppDependencies`'e aittir; burada yalnızca kendi notifier'ı kapatılır.
  void dispose() {
    pendingTarget.dispose();
  }
}
