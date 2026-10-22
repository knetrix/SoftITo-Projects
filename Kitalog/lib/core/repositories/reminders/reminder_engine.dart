/// Cihazda zamanlanacak tek bir bildirim: ne zaman, hangi metinle; dokununca
/// uygulamaya [payload] (`NotificationTargetModel.encode`) gelir.
typedef ScheduledNotification = ({DateTime at, String title, String body, String payload});

/// Bildirim kanalının kullanıcıya görünen adı ve açıklaması (Android ayarlarında görünür).
typedef ReminderChannel = ({String name, String description});

/// Bildirim türleri. Her grubun kendi kimlik aralığı ve Android kanalı vardır;
/// bir grubun planı yeniden kurulurken diğerinin bildirimlerine dokunulmaz.
enum ReminderGroup {
  /// İade hatırlatmaları. Aralık 1'den başlar: önceki sürümün kurduğu kimlikler de bu gruba düşer.
  loans(firstId: 1, channelId: 'loan_reminders'),

  /// Günlük okuma, okuma serisi ve yarım kalan kitap hatırlatmaları.
  reading(firstId: 10001, channelId: 'reading_reminders');

  const ReminderGroup({required this.firstId, required this.channelId});

  /// Bir grubun alabileceği en fazla bildirim kimliği.
  static const int capacity = 10000;

  final int firstId;
  final String channelId;

  bool owns(int id) => id >= firstId && id < firstId + capacity;
}

/// Yerel (cihaz üstü) bildirimlerin zamanlandığı motor. Uygulama
/// `flutter_local_notifications`'ı kullanır; testler sahte motor verir.
abstract class ReminderEngine {
  /// `false` ise (web, masaüstü) hatırlatma zamanlanmaz.
  bool get isSupported;

  /// Motoru hazırlar; kullanıcı bir bildirime dokunduğunda (uygulama açıkken
  /// veya arka plandayken) [onOpen] bildirimin `payload`'ıyla çağrılır.
  Future<void> initialize({required void Function(String payload) onOpen});

  /// Uygulama kapalıyken bir bildirime dokunularak açıldıysa o bildirimin `payload`'ı.
  Future<String?> launchPayload();

  /// Bildirim iznini ister (Android 13+, iOS); verildiyse `true`.
  Future<bool> requestPermission();

  /// [group]'un zamanlanmış bildirimlerini siler ve yerine [notifications]'ı kurar.
  Future<void> replaceGroup(ReminderGroup group, List<ScheduledNotification> notifications, ReminderChannel channel);
}

/// Bildirimin desteklenmediği platformlar (web, masaüstü) için motor.
class UnsupportedReminderEngine implements ReminderEngine {
  const UnsupportedReminderEngine();

  @override
  bool get isSupported => false;

  @override
  Future<void> initialize({required void Function(String payload) onOpen}) async {}

  @override
  Future<String?> launchPayload() async => null;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> replaceGroup(
    ReminderGroup group,
    List<ScheduledNotification> notifications,
    ReminderChannel channel,
  ) async {}
}
