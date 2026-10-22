import 'package:kitalog/core/repositories/reminders/reminder_engine.dart';

/// Bildirim kurmak yerine çağrıları grup grup kaydeden sahte hatırlatma motoru.
class FakeReminderEngine implements ReminderEngine {
  FakeReminderEngine({this.isSupported = true, this.launchedWith, this.grantPermission = true});

  @override
  final bool isSupported;

  /// Uygulama bu bildirime dokunularak açılmış gibi davranır.
  final String? launchedWith;
  final bool grantPermission;

  /// Motorun verdiği dokunma geri çağrısı; testler bildirime dokunmayı bununla taklit eder.
  void Function(String payload)? onOpen;

  int initializeCalls = 0;
  int permissionRequests = 0;
  final Map<ReminderGroup, int> replaceCallsByGroup = {};
  final Map<ReminderGroup, List<ScheduledNotification>> scheduledByGroup = {};
  final Map<ReminderGroup, ReminderChannel> channelByGroup = {};

  /// İade hatırlatmaları grubu (kısa yollar).
  int get replaceCalls => replaceCallsByGroup[ReminderGroup.loans] ?? 0;
  List<ScheduledNotification> get scheduled => scheduledByGroup[ReminderGroup.loans] ?? const [];
  ReminderChannel? get channel => channelByGroup[ReminderGroup.loans];

  /// Okuma hatırlatmaları grubu (kısa yollar).
  int get readingReplaceCalls => replaceCallsByGroup[ReminderGroup.reading] ?? 0;
  List<ScheduledNotification> get readingScheduled => scheduledByGroup[ReminderGroup.reading] ?? const [];
  ReminderChannel? get readingChannel => channelByGroup[ReminderGroup.reading];

  @override
  Future<void> initialize({required void Function(String payload) onOpen}) async {
    initializeCalls++;
    this.onOpen = onOpen;
  }

  @override
  Future<String?> launchPayload() async => launchedWith;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grantPermission;
  }

  @override
  Future<void> replaceGroup(
    ReminderGroup group,
    List<ScheduledNotification> notifications,
    ReminderChannel channel,
  ) async {
    replaceCallsByGroup[group] = (replaceCallsByGroup[group] ?? 0) + 1;
    scheduledByGroup[group] = notifications;
    channelByGroup[group] = channel;
  }
}
