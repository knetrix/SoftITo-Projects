import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'reminder_engine.dart';

/// `flutter_local_notifications` ile cihaz üstü zamanlanmış bildirimler
/// (yalnızca Android / iOS). İnternet veya sunucu gerekmez; Android'de cihaz
/// yeniden başlatılınca eklenti bildirimleri yeniden kurar.
class LocalNotificationsReminderEngine implements ReminderEngine {
  /// Bildirim çubuğundaki tek renkli uygulama simgesi (`flutter_launcher_icons` üretir).
  static const String _androidIcon = '@drawable/ic_launcher_monochrome';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static bool get platformSupported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  bool get isSupported => platformSupported;

  @override
  Future<void> initialize({required void Function(String payload) onOpen}) async {
    if (_ready) return;
    try {
      // İzin, uygulama açılışında değil kullanıcı ilk iade tarihli ödüncü
      // kaydettiğinde veya Ayarlar'da bir hatırlatmayı açtığında istenir ([requestPermission]).
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_androidIcon),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) onOpen(payload);
        },
      );
      _ready = true;
    } on PlatformException {
      _ready = false;
    }
  }

  @override
  Future<String?> launchPayload() async {
    if (!_ready) return null;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      final payload = details.notificationResponse?.payload;
      return payload == null || payload.isEmpty ? null : payload;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) return await android.requestNotificationsPermission() ?? false;
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> replaceGroup(
    ReminderGroup group,
    List<ScheduledNotification> notifications,
    ReminderChannel channel,
  ) async {
    if (!_ready) return;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        group.channelId,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    try {
      // Yalnızca bu grubun bekleyen bildirimleri silinip yeniden kurulur; diğer
      // grubun planı ve ekranda duran bildirimler korunur.
      for (final pending in await _plugin.pendingNotificationRequests()) {
        if (group.owns(pending.id)) await _plugin.cancel(id: pending.id);
      }
      final now = DateTime.now();
      for (final (index, n) in notifications.take(ReminderGroup.capacity).indexed) {
        // Eklenti geçmiş bir anı reddeder (plan ile kurulum arasında saat geçmiş olabilir).
        if (!n.at.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: group.firstId + index,
          // Tek seferlik bildirim; anın kendisi önemli olduğu için UTC yeterli
          // (saat dilimi veritabanı ve ek paket gerekmez).
          scheduledDate: tz.TZDateTime.from(n.at, tz.UTC),
          notificationDetails: details,
          // Kesin saatli alarm izni (SCHEDULE_EXACT_ALARM) istememek için esnek
          // zamanlama: sistem birkaç dakika geciktirebilir.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: n.title,
          body: n.body,
          payload: n.payload,
        );
      }
    } on PlatformException {
      // Bildirim kurulamazsa uygulama çalışmaya devam eder; bir sonraki değişiklikte yeniden denenir.
    }
  }
}
